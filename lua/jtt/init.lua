local M = {}
local converter = require('jtt.converter')

function M.convert_json_to_typescript()
  local filetype = vim.bo.filetype
  
  if not converter.is_json_buffer(filetype) then
    vim.notify("Current buffer is not JSON", vim.log.levels.ERROR)
    return
  end
  
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local json_string = table.concat(lines, "\n")
  
  local ok, result = pcall(converter.json_to_typescript, json_string)
  if not ok then
    vim.notify("Failed to convert JSON: " .. tostring(result), vim.log.levels.ERROR)
    return
  end
  
  vim.fn.setreg('+', result)
  vim.notify("TypeScript interfaces copied to clipboard!", vim.log.levels.INFO)
end

function M.setup(opts)
  opts = opts or {}
  
  vim.api.nvim_create_user_command('JsonToTypeScript', function()
    M.convert_json_to_typescript()
  end, {
    desc = 'Convert JSON in current buffer to TypeScript interfaces'
  })
end

return M