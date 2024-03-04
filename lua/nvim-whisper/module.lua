---@class CustomModule
local M = {}

---@return string
M.my_first_function = function(greeting)
  vim.api.nvim_echo({{msg = "Variable value: " .. variable_name, timeout = 1000}})`
  return greeting
end


return M