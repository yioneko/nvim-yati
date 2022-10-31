local config = require("nvim-yati.config")
local utils = require("nvim-yati.utils")
local debug = require("nvim-yati.debug")
local ts_utils = require("nvim-treesitter.ts_utils")
local M = {}

local function match_type_spec(node, type_spec)
  return (node:named() and vim.tbl_contains(type_spec.named or {}, node:type()))
    or (not node:named() and vim.tbl_contains(type_spec.literal or {}, node:type()))
end

local function should_indent(node, spec)
  local type = node:type()
  return vim.tbl_contains(spec.indent, type) or vim.tbl_contains(spec.indent_last, type)
end

local function should_ignore(node, spec)
  local type = node:type()
  return match_type_spec(node, spec.ignore_self)
    or match_type_spec(node, spec.ignore_outer)
    or vim.tbl_contains(spec.ignore_within, type)
end

local function get_node_indent_range(node, spec, bufnr)
  local start_line, end_line = node:range(), utils.get_normalized_end(node, bufnr)

  -- Try to expand the range if the start/end line is the adjacent to prev/next sibling
  -- This fix duplicate indent in list-like indent scope (sample.js#L255)
  local prev = node:prev_sibling()
  while prev and utils.get_normalized_end(prev, bufnr) == start_line and not should_ignore(prev, spec) do
    start_line = prev:start()
    prev = prev:prev_sibling()
  end

  local next = node:next_sibling()
  while next and next:start() == end_line and not should_ignore(next, spec) do
    end_line = utils.get_normalized_end(next, bufnr)
    next = next:next_sibling()
  end

  -- Use next sibling's start line as end line if this node has a last indent
  -- This fix issues with duplicate indent on the last node
  -- sample.js#L305
  if vim.tbl_contains(spec.indent_last, node:type()) and next then
    end_line = next:start()
  end
  return start_line, end_line
end

local function find_indent_block_with_missing(root, start_line, spec)
  for node, _ in root:iter_children() do
    if
      should_indent(node, spec)
      and node:start() == start_line
      and utils.try_find_child(node, function(child)
        return child:missing()
      end) ~= nil
    then
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
  --[[
  -- Check if the line only contains node of the current tree, this is needed to handle injection
  -- Example:
  --   const inject = css` /* Original upper_line */
  --     .foo {            /* Should be updated to this line */
  --       color: red;
  --     }
  --   `
  --]]
  do
    local upper_col
    upper_line, upper_col = tree:root():start()

    local col = utils.get_first_nonblank_col_at_line(upper_line, bufnr)
    if col < upper_col then
      if utils.get_normalized_end(tree:root(), bufnr) == upper_line then
        return 0
      end
      upper_line = upper_line + 1
    end
  end

  local indent = 0

  -- NOTE: Not work with 'vartabstop'
  local shift = vim.bo[bufnr].shiftwidth
  if shift <= 0 then
    shift = vim.bo[bufnr].tabstop
  end

  local node = utils.get_node_at_line(line, tree, false, bufnr)
  if not node then
    return -1
  end

  ---@return HookCtx
  local function make_ctx()
    return {
      bufnr = bufnr,
      indent = indent,
      lnum = line,
      node = node,
      shift = shift,
      tree = tree,
      upper_line = upper_line,
    }
  end

  do
    local ignored = utils.try_find_parent(node, function(parent)
      return vim.tbl_contains(spec.ignore_within, parent:type())
    end, 1)
    if ignored then
      -- Apply custom hooks here for special case of string and comment
      local cont = true
      indent, node, cont = spec.hook_node(make_ctx())
      if cont then
        -- Default handling
        if line ~= ignored:start() and not utils.node_has_injection(ignored, bufnr) then
          if utils.get_buf_line(bufnr, line):match("^%s*$") ~= nil then
            -- If the line is empty, use default smart indent
            return -1
          end
          return utils.cur_indent(line, bufnr) - utils.cur_indent(upper_line, bufnr)
        else
          node = ignored
        end
      end
    end
  end

  debug.log("Initial node", node:type())
  -- The line is empty
  if node:start() ~= line then
    local cont = true
    indent, node, cont = spec.hook_new_line(make_ctx())
    if indent < 0 then
      return -1
    end
    if cont then
      -- Try to find node above the current line as new indent base
      local prev_node
      do
        local cur_line = utils.prev_nonblank_lnum(line, bufnr)
        prev_node = utils.get_node_at_line(cur_line, tree, true, bufnr)

        -- Skip ignored nodes
        while prev_node and should_ignore(prev_node, spec) do
          cur_line = utils.prev_nonblank_lnum(cur_line, bufnr)
          if cur_line < upper_line then
            prev_node = nil
            break
          end
          prev_node = utils.get_node_at_line(cur_line, tree, true, bufnr)
        end
        if prev_node then
          --[[
          -- Try find node considered always 'open' for last indent
          -- Example:
          --   if true:
          --     some()
          --
          --     |
          --]]
          local last_open = utils.try_find_parent(prev_node, function(parent)
            return vim.tbl_contains(spec.indent_last_open, parent:type())
          end)
          if last_open then
            prev_node = last_open
          else
            --[[
            -- Try find indent node with missing child (usually 'end')
            -- Example:
            --   if true then
            --     |
            --   (end) <- missing
            --]]
            prev_node = find_indent_block_with_missing(prev_node, cur_line, spec)
          end
        end
      end
      -- If prev_node is contained inside, then we use prev_node as indent base
      if prev_node and utils.contains(node, prev_node) then
        node = prev_node
      end
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
  local start_line, end_line = get_node_indent_range(node, spec, bufnr)

  -- If the node is not at the same line and it's an indent node, we should indent
  if line ~= start_line and start_line >= upper_line and node:named() and should_indent(node, spec) then
    indent = indent + shift
  end

  if node:type() == "ERROR" then
    -- TODO: Better error handling
    debug.log("On error node at", start_line)
    return utils.cur_indent(start_line, bufnr) - utils.cur_indent(upper_line, bufnr)
  end

  debug.log("Traverse from:", node:type(), start_line)
  while start_line >= upper_line and node do
    if match_type_spec(node, spec.ignore_outer) then
      break
    end

    local cont = true
    indent, node, cont = spec.hook_node(make_ctx())
    if indent < 0 then
      return -1
    end
    -- If the new node is returned as is, we should continue to prevent infinite loop
    if cont then
      local parent = node:parent()
      if parent then
        if parent:type() == "ERROR" then
          debug.log("On error node at", parent:start())
          indent = indent + utils.cur_indent(start_line, bufnr) - utils.cur_indent(upper_line, bufnr)
          break
        end
        if
          parent:start() >= upper_line
          -- Do not indent for the same line range
          -- Use end line of the first node of parent to compare with start_line
          and (parent:start() ~= start_line or utils.get_normalized_end(parent, bufnr) ~= end_line)
        then
          local parent_type = parent:type()

          if
            should_indent(parent, spec)
            and not match_type_spec(node, spec.skip_child[parent_type] or {})
            and node:prev_sibling() -- Skip the first node
            and (node:next_sibling() ~= nil or vim.tbl_contains(spec.indent_last, parent_type)) -- Skip the last node
          then
            indent = indent + shift
          end
        end
        debug.log("Node:", node:type(), "Parent:", parent:type(), "Indent:", indent, "Line:", start_line, end_line)
      end

      node = parent
    end

    -- If the node is ignored (mainly test ignore_self), we should pass through it
    if node and not should_ignore(node, spec) then
      start_line, end_line = get_node_indent_range(node, spec, bufnr)
    end
  end
  debug.log("Traverse end")

  return indent
end

local function get_trees_at_pos(root_lang_tree, line, col)
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
      for _, tree in ipairs(lang_tree:trees()) do
        if ts_utils.is_in_node_range(tree:root(), line, col) and not trees_contains(tree, lang) then
          table.insert(trees, { tree, lang })
        end
      end
    end
  end, true)

  return trees
end

function M.get_indent(vlnum, bufnr)
  local lnum = (vlnum or vim.v.lnum) - 1
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local root_tree = utils.get_parser(bufnr)

  if not root_tree then
    return -1
  end
  -- Firstly, ensure the tree is updated
  if not root_tree:is_valid() then
    root_tree:parse()
  end

  local total_indent = 0

  local col = utils.get_first_nonblank_col_at_line(lnum, bufnr)
  local trees = get_trees_at_pos(root_tree, lnum, col)
  for _, tree in ipairs(trees) do
    local indent = get_indent_for_tree(lnum, tree[1], tree[2], bufnr)
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
