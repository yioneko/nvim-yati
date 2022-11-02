local o = require("nvim-yati.config")
local utils = require("nvim-yati.utils")

local function always_true()
  return true
end

local function create_cross_tree_stack(node, parser, filter)
  local nrange = utils.node_range(node, false)

  local trees = {}
  parser:for_each_tree(function(tree, lang_tree)
    local root = tree:root()
    local min_capture_node = root:descendant_for_range(nrange[1][1], nrange[1][2], nrange[2][1], nrange[2][2])

    while min_capture_node and not filter(min_capture_node) do
      min_capture_node = min_capture_node:parent()
    end
    if min_capture_node and utils.node_contains(min_capture_node, node) then
      table.insert(trees, {
        lang = lang_tree:lang(),
        tstree = tree,
        min_capture_node = min_capture_node,
      })
    end
  end)

  table.sort(trees, function(a, b)
    local is_same = utils.node_contains(a.min_capture_node, b.min_capture_node)
      and utils.node_contains(b.min_capture_node, a.min_capture_node)
    if is_same then
      return utils.node_contains(a.tstree:root(), b.tstree:root())
    end
    return utils.node_contains(a.min_capture_node, b.min_capture_node)
  end)

  return trees
end

---@class YatiContext
---@field node userdata
---@field bufnr integer
---@field lnum integer
---@field computed_indent integer
---@field shift integer
---@field stage "initial"|"traverse"
---@field tree_stack { tstree: userdata, lang: string, min_capture_node: userdata }[]
---@field parser LanguageTree
---@field filter fun(node: userdata):boolean
---@field has_fallback boolean
local Context = {}

---@param lnum integer
---@param bufnr integer
---@param filter fun(node: userdata):boolean
---@return YatiContext|nil
function Context:new(lnum, bufnr, filter)
  local obj = {
    lnum = lnum,
    stage = "initial",
    bufnr = bufnr,
    shift = utils.get_shift(bufnr),
    filter = filter or always_true,
    computed_indent = 0,
    tree_stack = {},
  }

  setmetatable(obj, { __index = self })

  local parser = utils.get_parser(bufnr)
  local node = utils.get_node_at_line(lnum, false, bufnr, filter)
  if not node then
    return
  end

  obj.node = node
  obj.parser = parser
  obj.tree_stack = create_cross_tree_stack(node, parser, filter)

  return obj
end

---@param self YatiContext
local function _peek_parent(self)
  if not self.node then
    return
  end
  local cur = self.node:parent()
  local stack_pos = #self.tree_stack - 1
  -- we need to check whether the new parent contains old node
  -- because `min_capture_node` is not always correct (multiple
  -- trees span same range)
  while not cur or not self.filter(cur) or not utils.node_contains(cur, self.node) do
    if cur then
      cur = cur:parent()
    elseif stack_pos >= 1 then
      cur = self.tree_stack[stack_pos].min_capture_node
      stack_pos = stack_pos - 1
    else
      return
    end
  end
  return cur, stack_pos + 1
end

---@return string|nil
function Context:lang()
  local entry = self.tree_stack[#self.tree_stack]
  if entry then
    return entry.lang
  end
end

---@return string|nil
function Context:parent_lang()
  local _, pos = _peek_parent(self)
  if pos ~= nil and pos >= 1 then
    return self.tree_stack[pos].lang
  end
end

---@return YatiNodesConfig|nil
function Context:config()
  local lang = self:lang()
  if lang then
    return o.get(lang).nodes
  end
end

---@return YatiNodesConfig|nil
function Context:parent_config()
  local lang = self:parent_lang()
  if lang then
    return o.get(lang).nodes
  end
end

---@return YatiHandler[]
function Context:handlers()
  local lang = self:lang()
  if lang then
    local handlers = o.get(lang).handlers
    if self.stage == "initial" then
      return handlers.on_initial
    else
      return handlers.on_traverse
    end
  end
  return {}
end

---@return YatiHandler[]
function Context:parent_handlers()
  local lang = self:parent_lang()
  if lang then
    local handlers = o.get(lang).handlers
    if self.stage == "initial" then
      return handlers.on_initial
    else
      return handlers.on_traverse
    end
  end
  return {}
end

---@return userdata|nil
function Context:parent()
  local node = _peek_parent(self)
  return node
end

---@return userdata|nil
function Context:prev_sibling()
  if not self.node then
    return
  end
  local cur = self.node:prev_sibling()
  while cur and not self.filter(cur) do
    cur = cur:prev_sibling()
  end
  return cur
end

---@return userdata|nil
function Context:next_sibling()
  if not self.node then
    return
  end
  local cur = self.node:next_sibling()
  while cur and not self.filter(cur) do
    cur = cur:next_sibling()
  end
  return cur
end

---@return userdata|nil
function Context:first_sibling()
  local parent = self:parent()
  if parent then
    for node in parent:iter_children() do
      if self.filter(node) then
        return node
      end
    end
  end
end

---@return userdata|nil
function Context:last_sibling()
  local parent = self:parent()
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

---@return userdata|nil
function Context:to_parent()
  if not self.node then
    return
  end
  local cur = self.node:parent()
  while not cur or not self.filter(cur) or not utils.node_contains(cur, self.node) do
    if cur then
      cur = cur:parent()
    elseif #self.tree_stack > 1 then
      table.remove(self.tree_stack)
      cur = self.tree_stack[#self.tree_stack].min_capture_node
    else
      break
    end
  end
  self.node = cur

  return self.node
end

---@param indent_delta integer
function Context:add(indent_delta)
  self.computed_indent = self.computed_indent + indent_delta
end

---@param indent integer
function Context:set(indent)
  self.computed_indent = indent
end

---@param new_node userdata
function Context:relocate(new_node, follow_parent)
  if new_node ~= self.node then
    if follow_parent then
      while not utils.node_contains(self.node, new_node) do
        self:to_parent()
      end
    else
      self.node = new_node
      self.tree_stack = create_cross_tree_stack(new_node, self.parser, self.filter)
    end
  end
  return true
end

function Context:begin_traverse()
  self.stage = "traverse"
end

function Context:parse()
  if not self.parser:is_valid() then
    self.parser:parse()
  end
end

function Context:fallback()
  self.has_fallback = true
  return false -- not continue
end

return Context
