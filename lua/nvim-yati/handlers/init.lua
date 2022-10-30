---@alias YatiInitialHandler fun(ctx: YatiInitialCtx, initialCursor: TSCursor): userdata|false|nil
---@alias YatiParentHandler fun(ctx: YatiParentCtx, cursor: TSCursor): boolean|nil

---@class YatiHandlers
---@field on_initial YatiInitialHandler[]
---@field on_parent YatiParentHandler[]

local default_handlers = require("nvim-yati.handlers.default")

local M = {}

---@param ctx YatiInitialCtx
---@param initial_cursor TSCursor
function M.handle_initial(ctx, initial_cursor)
  for _, handler in ipairs(ctx.handlers) do
    local initial_node_or_cont = handler(ctx, initial_cursor)
    if initial_node_or_cont == false then
      return false
    elseif initial_node_or_cont ~= nil then
      return initial_node_or_cont
    end
  end
  return default_handlers.on_initial(ctx, initial_cursor)
end

---@param ctx YatiParentCtx
---@param cursor TSCursor
function M.handle_parent(ctx, cursor)
  local handlers = {}
  vim.list_extend(handlers, ctx.handlers)
  vim.list_extend(handlers, ctx.parent_handlers or {})
  for _, handler in ipairs(handlers) do
    local should_cont = handler(ctx, cursor)
    if should_cont ~= nil then
      return should_cont
    end
  end
  return default_handlers.on_parent(ctx, cursor)
end

return M
