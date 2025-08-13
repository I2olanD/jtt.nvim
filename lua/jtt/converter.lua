local M = {}

function M.is_json_buffer(filetype)
  return filetype == 'json'
end

local function capitalize_first(str)
  return str:sub(1,1):upper() .. str:sub(2)
end

local function is_array(t)
  if type(t) ~= "table" then return false end
  if #t == 0 then return false end
  for i = 1, #t do
    if t[i] == nil then return false end
  end
  return true
end

local function is_object(t)
  return type(t) == "table" and not is_array(t)
end

local function collect_interfaces(value, key, interfaces)
  local t = type(value)
  if t == "table" then
    if is_array(value) then
      if #value > 0 and is_object(value[1]) then
        local interface_name = capitalize_first(key or "Item")
        if not interfaces[interface_name] then
          interfaces[interface_name] = value[1]
          -- Recursively collect from array items
          for k, v in pairs(value[1]) do
            collect_interfaces(v, k, interfaces)
          end
        end
        return interface_name .. "[]"
      elseif #value > 0 then
        return collect_interfaces(value[1], nil, interfaces) .. "[]"
      else
        return "any[]"
      end
    elseif is_object(value) then
      local interface_name = capitalize_first(key or "Unknown")
      if not interfaces[interface_name] then
        interfaces[interface_name] = value
        -- Recursively collect from object properties
        for k, v in pairs(value) do
          collect_interfaces(v, k, interfaces)
        end
      end
      return interface_name
    else
      return "any"
    end
  elseif t == "string" then
    return "string"
  elseif t == "number" then
    return "number"
  elseif t == "boolean" then
    return "boolean"
  else
    return "any"
  end
end

local function get_typescript_type(value, key)
  local t = type(value)
  if t == "string" then
    return "string"
  elseif t == "number" then
    return "number"
  elseif t == "boolean" then
    return "boolean"
  elseif t == "table" then
    if is_array(value) then
      if #value > 0 and is_object(value[1]) then
        return capitalize_first(key or "Item") .. "[]"
      elseif #value > 0 then
        return get_typescript_type(value[1], nil) .. "[]"
      else
        return "any[]"
      end
    elseif is_object(value) then
      return capitalize_first(key or "Unknown")
    else
      return "any"
    end
  else
    return "any"
  end
end

local function generate_interface(name, obj)
  local lines = {string.format("interface %s {", name)}
  
  local keys = {}
  for key in pairs(obj) do
    table.insert(keys, key)
  end
  table.sort(keys)
  
  for _, key in ipairs(keys) do
    local ts_type = get_typescript_type(obj[key], key)
    table.insert(lines, string.format("  %s: %s;", key, ts_type))
  end
  
  table.insert(lines, "}")
  return table.concat(lines, "\n")
end

function M.json_to_typescript(json_string)
  local decoded
  if vim and vim.json then
    local status
    status, decoded = pcall(vim.json.decode, json_string)
    if not status then
      error("Invalid JSON: " .. tostring(decoded))
    end
  else
    local json = require("jtt.json")
    decoded = json.decode(json_string)
  end
  
  -- First pass: collect all interfaces
  local interfaces = {}
  collect_interfaces(decoded, "Root", interfaces)
  
  -- Remove Root from interfaces since we handle it separately
  local root_data = interfaces["Root"]
  interfaces["Root"] = nil
  
  -- Sort interface names
  local interface_names = {}
  for name in pairs(interfaces) do
    table.insert(interface_names, name)
  end
  table.sort(interface_names)
  
  -- Generate all interfaces
  local result = {}
  for _, name in ipairs(interface_names) do
    table.insert(result, generate_interface(name, interfaces[name]))
  end
  
  -- Add Root interface at the end
  if root_data then
    table.insert(result, generate_interface("Root", root_data))
  else
    table.insert(result, generate_interface("Root", decoded))
  end
  
  return table.concat(result, "\n\n")
end

return M