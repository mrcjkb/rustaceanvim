local M = {}

local warnings = {}
local errors = {}
local is_json_config_loaded = false

---@param warning string
local function add_warning(warning)
  table.insert(warnings, warning)
end

---@param err string
local function add_error(err)
  table.insert(errors, err)
end

---@param field_name string | nil
---@param tbl unknown
---@param keys string[]
---@param value unknown
local function tbl_set(field_name, tbl, keys, value)
  local next = table.remove(keys, 1)
  if type(tbl) ~= 'table' then
    add_warning(([[
Ignored field '%s' of invalid type '%s': %s
Please refer to the rust-analyzer documentation at
https://rust-analyzer.github.io/manual.html#%s
]]):format(field_name, type(value), vim.inspect(value), field_name))
    return
  end
  if #keys > 0 then
    tbl[next] = tbl[next] or {}
    field_name = (field_name and field_name .. '.' or '') .. next
    tbl_set(field_name, tbl[next], keys, value)
  else
    tbl[next] = value
  end
end

---@param tbl table
---@param json_key string e.g. "rust-analyzer.check.overrideCommand"
---@param json_value unknown
local function override_tbl_values(tbl, json_key, json_value)
  local keys = vim.split(json_key, '%.')
  tbl_set(nil, tbl, keys, json_value)
end

---@param json_content string
---@return table
function M.silent_decode(json_content)
  warnings = {}
  errors = {}
  local ok, json_tbl = pcall(vim.json.decode, json_content)
  if not ok or type(json_tbl) ~= 'table' then
    add_error(('Failed to decode json: %s'):format(json_tbl or 'unknown error'))
    return {}
  end
  return json_tbl
end

---@param tbl table
---@param json_tbl { [string]: unknown }
---@param key_predicate? fun(string): boolean
function M.override_with_json_keys(tbl, json_tbl, key_predicate)
  if vim.tbl_isempty(json_tbl) then
    return
  end
  is_json_config_loaded = true
  for json_key, value in pairs(json_tbl) do
    if not key_predicate or key_predicate(json_key) then
      override_tbl_values(tbl, json_key, value)
    end
  end
end

---@param tbl table
---@param json_tbl { [string]: unknown }
function M.override_with_rust_analyzer_json_keys(tbl, json_tbl)
  M.override_with_json_keys(tbl, json_tbl, function(key)
    return vim.startswith(key, 'rust-analyzer')
  end)
end

function M.is_json_config_loaded()
  return is_json_config_loaded
end

function M.get_warnings()
  return warnings
end

function M.get_errors()
  return errors
end

return M
