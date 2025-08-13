package.path = package.path .. ";./lua/?.lua"

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s\nExpected: %s\nActual: %s", 
      message or "Assertion failed", tostring(expected), tostring(actual)))
  end
end

local function assert_true(value, message)
  assert_eq(value, true, message)
end

local function assert_false(value, message)
  assert_eq(value, false, message)
end

local function test(name, fn)
  local status, err = pcall(fn)
  if status then
    print("✓ " .. name)
  else
    print("✗ " .. name)
    print("  " .. tostring(err))
    os.exit(1)
  end
end

local converter = require('jtt.converter')

print("JSON to TypeScript Converter Tests")
print("===================================")

test("detects json buffer by filetype", function()
  assert_true(converter.is_json_buffer('json'))
end)

test("returns false for non-json filetype", function()
  assert_false(converter.is_json_buffer('lua'))
end)

test("converts simple JSON object to TypeScript interface", function()
  local json = [[{
  "name": "John",
  "age": 30,
  "active": true
}]]
  local result = converter.json_to_typescript(json)
  local expected = [[interface Root {
  active: boolean;
  age: number;
  name: string;
}]]
  assert_eq(result, expected)
end)

test("converts nested objects to separate interfaces", function()
  local json = [[{
  "user": {
    "id": 1,
    "name": "John"
  },
  "address": {
    "street": "123 Main St",
    "city": "New York"
  }
}]]
  local result = converter.json_to_typescript(json)
  local expected = [[interface Address {
  city: string;
  street: string;
}

interface User {
  id: number;
  name: string;
}

interface Root {
  address: Address;
  user: User;
}]]
  assert_eq(result, expected)
end)

test("handles arrays of objects", function()
  local json = [[{
  "users": [
    {"id": 1, "name": "John"},
    {"id": 2, "name": "Jane"}
  ],
  "tags": ["admin", "user", "guest"]
}]]
  local result = converter.json_to_typescript(json)
  local expected = [[interface Users {
  id: number;
  name: string;
}

interface Root {
  tags: string[];
  users: Users[];
}]]
  assert_eq(result, expected)
end)

test("handles deeply nested objects", function()
  local json = [[{
  "company": {
    "name": "Tech Corp",
    "address": {
      "street": "123 Main",
      "city": "NYC",
      "coordinates": {
        "lat": 40.7,
        "lng": -74.0
      }
    }
  }
}]]
  local result = converter.json_to_typescript(json)
  -- Check that all nested interfaces are created
  assert(result:match("interface Address"))
  assert(result:match("interface Company"))
  assert(result:match("interface Coordinates"))
  assert(result:match("interface Root"))
  -- Check that nested properties are correctly typed
  assert(result:match("coordinates: Coordinates"))
  assert(result:match("address: Address"))
end)