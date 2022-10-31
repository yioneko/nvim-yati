---@alias YatiHandler fun(ctx: YatiContext):boolean

---@class YatiHandlers
---@field on_initial YatiHandlers[]
---@field on_traverse YatiHandlers[]

local default_handlers = require("nvim-yati.handlers.default")

local M = {}

---@param ctx YatiContext
function M.handle_initial(ctx)
  for _, handler in ipairs(ctx:handlers() or {}) do
    local should_cont = handler(ctx)
    if should_cont ~= nil then
      return should_cont
    end
  end
  return default_handlers.on_initial(ctx)
end

---@param ctx YatiContext
function M.handle_traverse(ctx)
  local handlers = {}
  vim.list_extend(handlers, ctx:handlers() or {})
  vim.list_extend(handlers, ctx:parent_handlers() or {})
  for _, handler in ipairs(handlers) do
    local should_cont = handler(ctx)
    if should_cont ~= nil then
      return should_cont
    end
  end
  return default_handlers.on_traverse(ctx)
end

return M
