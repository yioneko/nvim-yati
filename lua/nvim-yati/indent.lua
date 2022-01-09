local api = vim.api
local config = require("nvim-yati.config")
local ts_utils = require("nvim-treesitter.ts_utils")
local debug = require("nvim-yati.debug")
local M = {}

local function get_first_nonblank_col_for_line(lnum, bufnr)
  local line = api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
  local _, col = string.find(line, "^%s*")
  return col or 0
end

local function get_node_at_line(lnum, tree, named, bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local root = tree:root()

  local col = get_first_nonblank_col_for_line(lnum, bufnr)
  if named then
    return root:named_descendant_for_range(lnum, col, lnum, col)
  else
    return root:descendant_for_range(lnum, col, lnum, col)
  end
end

local function has_missing(root)
  for node, _ in root:iter_children() do
    if node:missing() or has_missing(node) then
      return true
    end
  end
  return false
end

local function match_type_spec(node, type_spec)
  return (node:named() and vim.tbl_contains(type_spec.named or {}, node:type()))
    or (not node:named() and vim.tbl_contains(type_spec.literal or {}, node:type()))
end

local function should_indent(node, spec)
  local type = node:type()
  return vim.tbl_contains(spec.indent, type)
    or vim.tbl_contains(spec.indent_last, type)
    or vim.tbl_contains(spec.indent_last_new_line, type)
end

local function should_ignore(node, spec)
  local type = node:type()
  return match_type_spec(node, spec.ignore_self)
    or match_type_spec(node, spec.ignore_outer)
    or vim.tbl_contains(spec.ignore_within, type)
end

local function get_node_range(node, spec)
  local start_line, _, end_line, _ = node:range()

  -- Use next sibling's start line as end line if this node has a last indent
  -- This fix issues with duplicate indent on the last node
  local is_indent_last = vim.tbl_contains(spec.indent_last, node:type())
    or vim.tbl_contains(spec.indent_last_new_line, node:type())
  if is_indent_last and node:next_sibling() then
    end_line = node:next_sibling():start()
  end
  return start_line, end_line
end

local function find_indent_block_with_missing(root, start_line, spec)
  for node, _ in root:iter_children() do
    if should_indent(node, spec) and node:start() == start_line and has_missing(node) then
      return node
    end
  end
end

local function get_indent_for_tree(line, tree, lang, bufnr)
  local spec = config.get_config(lang)
  if not spec then
    return 0
  end

  local upper_line
  -- Check if the line only contains node of the current tree, this is needed to handle injection
  do
    local upper_col
    upper_line, upper_col = tree:root():start()

    local col = get_first_nonblank_col_for_line(line, bufnr)
    if col < upper_col then
      if tree:root():end_() == upper_line then
        return 0
      end
      upper_line = upper_line + 1
    end
  end

  local indent = 0
  local shift = vim.bo.shiftwidth -- TODO: Work with tabstop

  local node = get_node_at_line(line, tree, false, bufnr)
  if
    not node --[[ or match_type_spec(node, ignore_spec) ]]
  then
    return -1
  end

  local containing_node = get_node_at_line(line, tree, true, bufnr)
  if vim.tbl_contains(spec.ignore_within, containing_node:type()) then
    return vim.fn.indent(line + 1)
  end

  debug.log("Initial node", node:type())
  -- The line is empty
  if node:start() ~= line then
    node = containing_node

    local prev_node
    do
      -- TODO: Replace this with a lua function and work with bufnr
      local cur_line = vim.fn.prevnonblank(line) - 1
      prev_node = get_node_at_line(cur_line, tree, true, bufnr)

      -- Skip ignored nodes
      while prev_node and should_ignore(prev_node, spec) do
        cur_line = vim.fn.prevnonblank(cur_line) - 1
        if cur_line < upper_line then
          prev_node = nil
          break
        end
        prev_node = get_node_at_line(cur_line, tree, true, bufnr)
      end
      if not spec.indent_last_open and prev_node then
        prev_node = find_indent_block_with_missing(prev_node, prev_node:start(), spec)
      end
    end
    -- If prev_node is contained, then we use prev_node as indent base
    if prev_node and prev_node:start() > node:start() then
      node = prev_node
    end
  end

  -- Skip ignored node, their start_line should be igored
  while node and should_ignore(node, spec) do
    -- If the node should be ignored for outer scope, not calcuate its indent at all
    -- Used to handle the macros in c
    if match_type_spec(node, spec.ignore_outer) then
      return indent
    end
    node = node:parent()
  end

  if not node then
    return -1
  end
  local start_line, end_line = get_node_range(node, spec)

  if node:type() == "ERROR" then
    -- TODO: Better error handling
    debug.log("On error node at", start_line)
    if line == start_line then
      -- If the line of node is the same as line calcuated for indent, return 0 to maintain the idempotency
      -- TODO: Replace this with a lua function and work with bufnr
      return vim.fn.indent(line + 1) - vim.fn.indent(upper_line + 1)
    else
      return vim.fn.indent(start_line + 1) - vim.fn.indent(upper_line + 1)
    end
  end

  if node:named() and should_indent(node, spec) then
    indent = indent + shift
  end

  debug.log("Traverse from:", node:type(), start_line)
  while start_line >= upper_line and node do
    if match_type_spec(node, spec.ignore_outer) then
      return indent
    end

    local parent = node:parent()
    if parent then
      if parent:type() == "ERROR" then
        debug.log("On error node at", parent:start())
        if line == start_line then
          indent = vim.fn.indent(line + 1) - vim.fn.indent(upper_line + 1)
        else
          indent = indent + vim.fn.indent(start_line + 1) - vim.fn.indent(upper_line + 1)
        end
        break
      end

      -- Do not indent for the same line range
      if parent:start() ~= start_line or parent:end_() ~= end_line then
        local parent_type = parent:type()

        if
          should_indent(parent, spec)
          and not match_type_spec(node, spec.skip_child[parent_type] or {})
          and node:prev_sibling() -- Skip the first node
          and (
            node:next_sibling() ~= nil
            or vim.tbl_contains(spec.indent_last, parent_type)
            or (vim.tbl_contains(spec.indent_last_new_line, parent_type) and node:prev_sibling():end_() ~= start_line)
          ) -- Skip the last node
        then
          indent = indent + shift
        end
      end
      debug.log("Node:", node:type(), "Parent:", parent:type(), "Indent:", indent, "Line:", start_line, end_line)
    end

    node = parent
    -- If the node is ignored (mainly test ignore_self), we should pass through it
    if node and not should_ignore(node, spec) then
      start_line, end_line = get_node_range(node, spec)
    end
  end
  debug.log("Traverse end")

  return indent
end

local function get_trees_for_position(root_lang_tree, line, col)
  local trees = {}

  -- Test whether the tree is duplicated
  local function trees_contains(tree, lang)
    for _, t in ipairs(trees) do
      local srow1, scol1, erow1, ecol1 = t[1]:root():range()
      local srow2, scol2, erow2, ecol2 = tree:root():range()
      if t[2] == lang and srow1 == srow2 and scol1 == scol2 and erow1 == erow2 and ecol1 == ecol2 then
        return true
      end
    end
    return false
  end

  root_lang_tree:for_each_child(function(lang_tree, lang)
    if lang_tree:contains({ line, col, line, col }) then
      lang_tree:for_each_tree(function(tree)
        if ts_utils.is_in_node_range(tree:root(), line, col) and not trees_contains(tree, lang) then
          table.insert(trees, { tree, lang })
        end
      end)
    end
  end, true)

  return trees
end

function M.get_indent(line, bufnr)
  line = (line or vim.v.lnum) - 1
  bufnr = bufnr or api.nvim_get_current_buf()

  local root_tree = vim.treesitter.get_parser(bufnr)

  if not root_tree then
    return -1
  end
  -- Firstly, ensure the tree is updated
  if not root_tree:is_valid() then
    root_tree:parse()
  end

  local total_indent = 0

  local col = get_first_nonblank_col_for_line(line, bufnr)
  local trees = get_trees_for_position(root_tree, line, col)
  for _, tree in ipairs(trees) do
    local indent = get_indent_for_tree(line, tree[1], tree[2], bufnr)
    if indent < 0 then
      return -1
    else
      total_indent = total_indent + indent
    end
    debug.log("Indent for tree", tree[2], ":", indent)
  end

  debug.log("Total indent:", total_indent)
  return total_indent
end

return M
