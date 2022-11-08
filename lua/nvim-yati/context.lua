local utils = require("nvim-yati.utils")

local function always_true()
  return true
end

local function create_cross_tree_stack(node, parser, filter)
  local sr, sc, er, ec = node:range()

  local trees = {}
  parser:for_each_tree(function(tree, lang_tree)
    local root = tree:root()
    local min_capture_node = root:descendant_for_range(sr, sc, er, ec)

    while min_capture_node and not filter(min_capture_node, lang_tree:lang()) do
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
    local is_same = utils.node_contains(a.tstree:root(), b.tstree:root())
      and utils.node_contains(b.tstree:root(), a.tstree:root())
    if is_same then
      return utils.node_contains(a.min_capture_node, b.min_capture_node)
    end
    return utils.node_contains(a.tstree:root(), b.tstree:root())
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
---@field filter fun(node: userdata, lang: string|nil):boolean
---@field cget fun(lang: string):YatiLangConfig|nil
---@field has_fallback boolean
local Context = {}

---@param lnum integer
---@param bufnr integer
---@param filter fun(node: userdata):boolean
---@param cget fun(lang: string):YatiLangConfig|nil
---@return YatiContext|nil
function Context:new(lnum, bufnr, filter, cget)
  local obj = {
    lnum = lnum,
    stage = "initial",
    bufnr = bufnr,
    shift = utils.get_shift(bufnr),
    filter = filter or always_true,
    cget = cget,
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
  while
    not cur
    or not self.filter(cur, self.tree_stack[stack_pos + 1].lang)
    or not utils.node_contains(cur, self.node)
  do
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

---@return YatiLangConfig|nil
function Context:conf()
  local lang = self:lang()
  if lang then
    return self.cget(lang)
  end
end

---@return YatiLangConfig|nil
function Context:p_conf()
  local lang = self:parent_lang()
  if lang then
    return self.cget(lang)
  end
end

---@return YatiNodesConfig|nil
function Context:nodes_conf()
  local conf = self:conf()
  if conf then
    return conf.nodes
  end
end

---@return YatiNodesConfig|nil
function Context:p_nodes_conf()
  local conf = self:p_conf()
  if conf then
    return conf.nodes
  end
end

---@return YatiHandler[]
function Context:handlers()
  local conf = self:conf()
  if conf then
    local handlers = conf.handlers
    if self.stage == "initial" then
      return handlers.on_initial
    else
      return handlers.on_traverse
    end
  end
  return {}
end

---@return YatiHandler[]
function Context:p_handlers()
  local conf = self:p_conf()
  if conf then
    local handlers = conf.handlers
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
  while cur and not self.filter(cur, self:lang()) do
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
  while cur and not self.filter(cur, self:lang()) do
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
      if self.filter(node, self:lang()) then
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
  while
    not cur
    or not self.filter(cur, self.tree_stack[#self.tree_stack].lang)
    or not utils.node_contains(cur, self.node)
  do
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
      while self.node and not utils.node_contains(self.node, new_node) do
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
