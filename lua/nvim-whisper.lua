-- main module file
local module = require("nvim-whisper.module")

---@class Config
---@field opt string Your config option
local config = {
  lsp = "/home/james/src/whisper.cpp/lsp"
}

---@class NvimWhisper
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.start = function()
  return module.start_transcription(M.config.opt)
end

return M
