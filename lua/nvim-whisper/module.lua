-- Create a message
local function createMessage()
  local request = {
    jsonrpc = "2.0",
    id = 1,
    method = "unguided",
    params = {dummy = 'nil'}
  }
  local request_str = vim.fn.json_encode(request)
  local content_length = #request_str
  local header = "Content-Length: " .. content_length .. "\r\n\r\n"
  local message = header .. request_str
  return message
end

local message = createMessage()
local job_id

-- Setup subprocess
local function setupSubprocess()
  local lsp_command = "/home/james/src/whisper.cpp/lsp"
  local lsp_opts = {
    cwd = "/home/james/src/whisper.cpp",
    on_stdout = function(job_id, data, event)
      -- Process stdout data here
      -- vim.api.nvim_put(data, "l", true, true)
      for _, response_str in ipairs(data) do
        -- print("local response " .. response_str)
        if response_str:sub(1, 1) == "{" then
          local response_json = vim.fn.json_decode(response_str)
          local result = response_json.result and response_json.result.transcription
          if result then
            print("result back " .. result)
            vim.api.nvim_put({result}, "l", false, true)
          end
        end
      end
      vim.fn.chansend(job_id, message)
    end,
    on_stderr = function(job_id, data, event)
      if data then
        for _, response_str in ipairs(data) do
          print("error " .. response_str)
        end
        -- vim.api.nvim_put({ "error"  }, "l", true, true)
        -- vim.api.nvim_put(data, "l", true, true)
      end
    end,
    on_exit = function(job_id, exit_code, event)
      print("Subprocess terminated with exit code", exit_code)
    end,
    stdout_buffered = false,
    stderr_buffered = false
  }
  local job_id = vim.fn.jobstart({lsp_command}, lsp_opts)
  return job_id
end

local function splitByNewlines(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^\n]+)") do
      table.insert(t, str)
  end
  return t
end

-- Main function
local function startProcess()
  job_id = setupSubprocess()
  -- vim.api.nvim_put(splitByNewlines(message), "l", true, true)
  vim.fn.chansend(job_id, message)
end

---@class CustomModule
local M = {}

---@return string
M.start_transcription = function(lsp)
  startProcess()
end

return M
