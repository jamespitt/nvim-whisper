
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

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local log_file

local function logger(log_type, log_message)
  if message == nil then
    return
  end
  if log_file == nil then
    local ok, err = pcall(function()
      log_file = io.open("/tmp/nvim_log.log", "a")
    end)
    if not ok then
      print("Could not open log file: " .. err)
      return
    end
  end
  local current_time = os.date("%Y-%m-%d %H:%M:%S")
  local ok, err = pcall(function()
    log_file:write(current_time .. " - " .. log_type .. " .. " .. log_message .. "\n")
    log_file:flush()
  end)
  if not ok then
    print("Could not write to log file: " .. err)
  end
end


-- Setup subprocess
local function setupSubprocess()
  local lsp_command = {"/home/james/src/whisper.cpp/lsp",}
                        -- "-m","models/ggml-medium.en.bin",}
                        -- "-mt","128"}
  local lsp_opts = {
    cwd = "/home/james/src/whisper.cpp",
    on_stdout = function(job_id, data, event)
      -- Process stdout data here
      vim.fn.chansend(job_id, message)
      logger("sent", message)
      -- vim.api.nvim_put(data, "l", true, true)
      for _, response_str in ipairs(data) do
        print("local response " .. response_str)
        logger("stdout", response_str)
        -- vim.api.nvim_put({response_str}, "l", false, true)
        if response_str:sub(1, 1) == "{" then
          local response_json = vim.fn.json_decode(response_str)
          local result = response_json.result and response_json.result.transcription
          if result then
            print("result back " .. result)
            vim.api.nvim_put({trim(result)}, "", true, true)
          end
        end
      end
    end,
    on_stderr = function(job_id, data, event)
      if data then
        for _, response_str in ipairs(data) do
          print("error " .. response_str .. '\n')
          logger("error", response_str)
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
  local job_id = vim.fn.jobstart(lsp_command, lsp_opts)
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
  logger("sent", message)
end

---@class CustomModule
local M = {}

---@return string
M.start_transcription = function(lsp)
  startProcess()
end

return M
