---@alias YatiInitialHandler fun(ctx: YatiInitialCtx): userdata|nil
---@alias YatiParentHandler fun(ctx: YatiParentCtx, cursor: TSCursor): boolean|nil

---@class YatiHandlers
---@field on_initial YatiInitialHandler[]
---@field on_parent YatiParentHandler[]

local M = {}

---@param ctx YatiInitialCtx
function M.handle_initial(ctx)
  local handlers = ctx.handlers
  for _, handler in ipairs(handlers) do
    local initial_node = handler(ctx)
    if initial_node then
      return initial_node
    end
  end
end

---@param ctx YatiParentCtx
---@param cursor TSCursor
function M.handle_parent(ctx, cursor)
  local handlers = ctx.handlers
  for _, handler in ipairs(handlers) do
    local should_cont = handler(ctx, cursor)
    if should_cont ~= nil then
      return should_cont
    end
  end
end

return M
