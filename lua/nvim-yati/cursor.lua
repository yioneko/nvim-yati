-- Cross tree node cursor
local utils = require("nvim-yati.utils")

local function always_true()
  return true
end

local meaningless_nodes = { "source", "document" }

---@class TSCursor
---@field node userdata
---@field tree_stack table
---@field parser table
---@field filter function
local TSCursor = {}

---@return TSCursor
function TSCursor:new(node, parser, filter)
  local o = {
    node = node,
    parser = parser,
    filter = filter or always_true,
    tree_stack = {},
  }

  setmetatable(o, { __index = self })

  local nrange = utils.node_range_inclusive(node)

  local trees = {}
  parser:for_each_child(function(lang_tree, lang)
    lang_tree:for_each_tree(function(tstree)
      local root = tstree:root()
      local min_capture_node = root:descendant_for_range(nrange[1][1], nrange[1][2], nrange[2][1], nrange[2][2])

      if
        not vim.tbl_contains(meaningless_nodes, min_capture_node:type()) and utils.node_contains(min_capture_node, node)
      then
        print(vim.inspect(utils.node_range_inclusive(min_capture_node)))
        print(min_capture_node:type())
        table.insert(trees, {
          lang = lang,
          tstree = tstree,
          min_capture_node = min_capture_node,
        })
      end
    end)
  end, true)

  table.sort(trees, function(a, b)
    return utils.node_contains(a.min_capture_node, b.min_capture_node)
  end)

  o.tree_stack = trees

  return o
end

function TSCursor:deref()
  return self.node
end

function TSCursor:lang()
  local entry = self.tree_stack[#self.tree_stack]
  if entry then
    return entry.lang
  end
end

local function wrap_move_check(fun)
  return function(self, ...)
    if not self.node then
      return
    end

    local args = { ... }
    local iter = function()
      fun(self, unpack(args))
      return self.node
    end
    for node in iter do
      if self.filter(node) then
        return node
      end
    end
  end
end

function TSCursor:peek_parent()
  if not self.node then
    return
  end
  local cur = self.node:parent()
  local stack_pos = #self.tree_stack - 1
  while not cur or not self.filter(cur) do
    if cur then
      cur = cur:parent()
    elseif stack_pos >= 1 then
      cur = self.tree_stack[stack_pos].min_capture_node
      stack_pos = stack_pos - 1
    else
      return
    end
  end
  return cur
end

function TSCursor:peek_prev_sibling()
  if not self.node then
    return
  end
  local cur = self.node:prev_sibling()
  while cur and not self.filter(cur) do
    cur = cur:prev_sibling()
  end
  return cur
end

function TSCursor:peek_next_sibling()
  if not self.node then
    return
  end
  local cur = self.node:next_sibling()
  while cur and not self.filter(cur) do
    cur = cur:next_sibling()
  end
  return cur
end

function TSCursor:peek_first_sibling()
  local parent = self:peek_parent()
  if parent then
    for node in parent:iter_children() do
      if self.filter(node) then
        return node
      end
    end
  end
end

function TSCursor:peek_last_sibling()
  local parent = self:peek_parent()
  if parent then
    local res
    for node in parent:iter_children() do
      if self.filter(node) then
        res = node
      end
    end
    if res then
      return res
    end
  end
end

---@param self TSCursor
local function unchecked_to_parent(self)
  local parent = self.node:parent()
  if not parent and #self.tree_stack > 1 then
    table.remove(self.tree_stack)
    parent = self.tree_stack[#self.tree_stack].min_capture_node
  end

  self.node = parent
end

---@param self TSCursor
local function unchecked_to_prev_sibling(self)
  self.node = self:peek_prev_sibling()
end

---@param self TSCursor
local function unchecked_to_next_sibling(self)
  self.node = self:peek_next_sibling()
end

---@param self TSCursor
local function unchecked_to_first_sibling(self)
  self.node = self:peek_first_sibling()
end

---@param self TSCursor
local function unchecked_to_last_sibling(self)
  self.node = self:peek_last_sibling()
end

TSCursor.to_parent = wrap_move_check(unchecked_to_parent)
TSCursor.to_prev_sibling = wrap_move_check(unchecked_to_prev_sibling)
TSCursor.to_next_sibling = wrap_move_check(unchecked_to_next_sibling)
TSCursor.to_first_sibling = wrap_move_check(unchecked_to_first_sibling)
TSCursor.to_last_sibling = wrap_move_check(unchecked_to_last_sibling)

return TSCursor
