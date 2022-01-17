---@alias Chain fun(ctx: HookCtx): number | nil, tsnode | nil

---@class Hook
---@field chains Chain[]

---@type Hook
local Hook = {}
Hook.__index = Hook

---@vararg Chain
---@return Hook
function Hook.new(...)
  local self = setmetatable({}, Hook)
  self.chains = { ... }
  return self
end

function Hook:add(chain)
  table.insert(self.chains, chain)
end

---@param ctx HookCtx
---@return number indent, tsnode node, boolean hooked
function Hook:__call(ctx)
  for _, chain in ipairs(self.chains) do
    local inc, next_node = chain(ctx)
    if inc ~= nil then
      if inc < 0 then
        return -1, nil, true
      else
        return ctx.indent + inc, next_node, true
      end
    end
  end
  return ctx.indent, ctx.node, false
end

return Hook.new
