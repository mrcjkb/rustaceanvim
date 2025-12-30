local M = {}

---@param input string unparsed snippet
---@return string parsed snippet
local function parse_snippet_fallback(input)
  local output = input
    -- $0 -> Nothing
    :gsub('%$%d', '')
    -- ${0:_} -> _
    :gsub('%${%d:(.-)}', '%1')
    :gsub([[\}]], '}')
  return output
end

---@param input string unparsed snippet
---@return string parsed snippet
local function parse_snippet(input)
  local ok, parsed = pcall(function()
    return vim.lsp._snippet_grammar.parse(input)
  end)
  return ok and tostring(parsed) or parse_snippet_fallback(input)
end

---@param text_edits? rustaceanvim.lsp.TextEdit[]
function M.snippet_text_edits_to_text_edits(text_edits)
  if type(text_edits) ~= 'table' then
    return
  end
  for _, value in ipairs(text_edits) do
    if value.newText and value.insertTextFormat then
      value.newText = parse_snippet(value.newText)
    end
  end
end

---@param arg_list string[] list of arguments
---@return string[] runner args
---@return string[] executable args
local function partition_executable_args(arg_list)
  local delimiter = '--'
  local before = {}
  local after = {}
  local found_delimiter = false

  for _, value in ipairs(arg_list) do
    if value == delimiter then
      found_delimiter = true
    elseif not found_delimiter then
      table.insert(before, value)
    else
      table.insert(after, value)
    end
  end

  return before, after
end

---Transforms test args to cargo-nextest args if it is detected.
---@param args string[]
---@return string[] args
function M.maybe_nextest_transform(args)
  if vim.fn.executable('cargo-nextest') ~= 1 or args[1] ~= 'test' then
    return args
  end
  args = vim.deepcopy(args)
  args[1] = 'run'
  table.insert(args, 1, 'nextest')
  local nextest_args, executable_args = partition_executable_args(args)

  -- specify custom profile for junit output
  table.insert(nextest_args, '--profile')
  table.insert(nextest_args, 'rustaceanvim')
  table.insert(nextest_args, '--config-file')
  table.insert(nextest_args, require('rustaceanvim.cache').nextest_config_path())

  -- tranform:
  -- - `-- --exact foo` -> `-- foo`
  for i = 1, #executable_args do
    if executable_args[i] == '--exact' then
      local test_name = executable_args[i - 1]
      table.remove(executable_args, i - 1)
      table.remove(executable_args, i - 1)
      table.insert(nextest_args, test_name)
      break
    end
  end

  -- these flags are unsupported by cargo-nextest and should be removed.
  ---@type table<string, true>
  local nextest_unsupported_flags = {
    ['--show-output'] = true,
    -- nocapture is supported, but disables junit capturing in recent nextest versions
    ['--nocapture'] = true,
  }
  local indexes_to_remove_reverse_order = {}
  for i, arg in ipairs(executable_args) do
    if nextest_unsupported_flags[arg] then
      table.insert(indexes_to_remove_reverse_order, 1, i)
    end
  end
  for _, i in pairs(indexes_to_remove_reverse_order) do
    table.remove(executable_args, i)
  end

  if #executable_args > 0 then
    table.insert(nextest_args, '--')
  end
  for _, v in ipairs(executable_args) do
    table.insert(nextest_args, v)
  end
  return nextest_args
end

-- sanitize_command_for_debugging substitutes the command arguments so it can be used to run a
-- debugger.
--
-- @param command should be a table like: { "run", "--package", "<program>", "--bin", "<program>" }
-- For some reason the endpoint textDocument/hover from rust-analyzer returns
-- cargoArgs = { "run", "--package", "<program>", "--bin", "<program>" } for Debug entry.
-- It doesn't make any sense to run a program before debugging.  Even more the debugging won't run if
-- the program waits some input.  Take a look at rust-analyzer/editors/code/src/toolchain.ts.
---@param command string[]
function M.sanitize_command_for_debugging(command)
  if command[1] == 'run' then
    command[1] = 'build'
  elseif command[1] == 'test' and not vim.list_contains(command, '--no-run') then
    table.insert(command, 2, '--no-run')
  end
end

---Undo sanitize_command_for_debugging.
---@param command string[]
function M.undo_debug_sanitize(command)
  if command[1] == 'build' then
    command[1] = 'run'
  elseif command[1] == 'test' and command[2] == '--no-run' then
    table.remove(command, 2)
  end
end

return M
