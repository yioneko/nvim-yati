local M = {
  enable = vim.env.DEBUG_YATI,
  disabled_context = {},
}

setmetatable(M, {
  __call = function(_, context, msg)
    if M.enable and not M.disabled_context[context] then
      print(string.format("[nvim-yati][%s]: ", context) .. msg)
    end
  end,
})

function M.toggle()
  M.enable = not M.enable
end

function M.disable(context)
  M.disabled_context[context] = true
end

return M
