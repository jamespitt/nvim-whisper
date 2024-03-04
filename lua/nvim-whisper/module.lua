---@class CustomModule
local M = {}

---@return string
M.start_transcription = function(greeting)
  vim.api.nvim_echo({{"Variable value: " .. greeting,}}, false, {})
  return greeting
end


return M
