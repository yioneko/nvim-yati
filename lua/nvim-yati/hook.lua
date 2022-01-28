---@class Hook
---@field chains Chain[]
local Hook = {}
Hook.__index = Hook

---@vararg Chain
---@return Hook
function Hook.new(...)
  local self = setmetatable({}, Hook)
  self.chains = { ... }
  return self
end

---@vararg Chain
function Hook:add(...)
  local new_chains = { ... }
  for _, chain in ipairs(new_chains) do
    table.insert(self.chains, chain)
  end
end

---@param ctx HookCtx
---@return number indent, tsnode node, boolean cont
function Hook:__call(ctx)
  local prev_id = ctx.node:id()

  for _, chain in ipairs(self.chains) do
    local inc, next_node, cont = chain(ctx)
    if inc ~= nil then
      if inc < 0 then
        return -1, nil, false
      else
        local next_id = next_node and next_node:id()
        if cont == nil then
          cont = next_id ~= nil and prev_id == next_id
        end
        return ctx.indent + inc, next_node, cont
      end
    end
  end
  return ctx.indent, ctx.node, true
end

return Hook.new
