---@class CustomModule
local M = {}

---@return string
M.my_first_function = function(greeting)
  vim.api.nvim_echo({{"Variable value: " .. greeting,}}, false, {})
  return greeting
end


return M
