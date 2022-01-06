local M = {
  flag = true,
}

function M.log(...)
  if M.flag then
    print(...)
  end
end

function M.toggle()
  M.flag = not M.flag
end

return M
