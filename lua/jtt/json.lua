local M = {}

function M.decode(str)
  local pos = 1
  
  local function skip_whitespace()
    while pos <= #str and str:sub(pos, pos):match("%s") do
      pos = pos + 1
    end
  end
  
  local function parse_string()
    if str:sub(pos, pos) ~= '"' then
      error("Expected string")
    end
    pos = pos + 1
    local start = pos
    while pos <= #str do
      if str:sub(pos, pos) == '"' and str:sub(pos-1, pos-1) ~= '\\' then
        local result = str:sub(start, pos-1)
        pos = pos + 1
        return result
      end
      pos = pos + 1
    end
    error("Unterminated string")
  end
  
  local function parse_number()
    local start = pos
    if str:sub(pos, pos) == '-' then pos = pos + 1 end
    while pos <= #str and str:sub(pos, pos):match("%d") do
      pos = pos + 1
    end
    if str:sub(pos, pos) == '.' then
      pos = pos + 1
      while pos <= #str and str:sub(pos, pos):match("%d") do
        pos = pos + 1
      end
    end
    return tonumber(str:sub(start, pos-1))
  end
  
  local function parse_value()
    skip_whitespace()
    local char = str:sub(pos, pos)
    
    if char == '"' then
      return parse_string()
    elseif char == '{' then
      pos = pos + 1
      local obj = {}
      skip_whitespace()
      
      if str:sub(pos, pos) == '}' then
        pos = pos + 1
        return obj
      end
      
      while true do
        skip_whitespace()
        local key = parse_string()
        skip_whitespace()
        if str:sub(pos, pos) ~= ':' then
          error("Expected ':'")
        end
        pos = pos + 1
        skip_whitespace()
        obj[key] = parse_value()
        skip_whitespace()
        
        if str:sub(pos, pos) == '}' then
          pos = pos + 1
          return obj
        elseif str:sub(pos, pos) == ',' then
          pos = pos + 1
        else
          error("Expected ',' or '}'")
        end
      end
    elseif char == '[' then
      pos = pos + 1
      local arr = {}
      skip_whitespace()
      
      if str:sub(pos, pos) == ']' then
        pos = pos + 1
        return arr
      end
      
      while true do
        skip_whitespace()
        table.insert(arr, parse_value())
        skip_whitespace()
        
        if str:sub(pos, pos) == ']' then
          pos = pos + 1
          return arr
        elseif str:sub(pos, pos) == ',' then
          pos = pos + 1
        else
          error("Expected ',' or ']'")
        end
      end
    elseif str:sub(pos, pos+3) == "true" then
      pos = pos + 4
      return true
    elseif str:sub(pos, pos+4) == "false" then
      pos = pos + 5
      return false
    elseif str:sub(pos, pos+3) == "null" then
      pos = pos + 4
      return nil
    elseif char:match("[%-0-9]") then
      return parse_number()
    else
      error("Unexpected character: " .. char)
    end
  end
  
  return parse_value()
end

return M