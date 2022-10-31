local M = {
  enable = false,
}

setmetatable(M, {
  __call = function(_, msg)
    if M.enable then
      print("[nvim-yati]: " .. msg)
    end
  end,
})

function M.toggle()
  M.enable = not M.enable
end

return M
