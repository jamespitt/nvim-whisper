---@class CustomModule
local M = {}

---@return string
M.my_first_function = function(greeting)
  vim.api.nvim_echo({{msg = "Variable value: " .. greeting, timeout = 1000}}, false, {})
  return greeting
end


return M
