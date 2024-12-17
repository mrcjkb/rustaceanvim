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

---Transforms the args to cargo-nextest args if it is detected.
---Mutates command!
---@param args string[]
function M.try_nextest_transform(args)
  if vim.fn.executable('cargo-nextest') ~= 1 then
    return args
  end
  if args[1] == 'test' then
    args[1] = 'run'
    table.insert(args, 1, 'nextest')
  end
  if args[#args] == '--nocapture' then
    table.insert(args, 3, '--nocapture')
    table.remove(args, #args)
  end
  local nextest_unsupported_flags = {
    '--show-output',
  }
  local indexes_to_remove_reverse_order = {}
  for i, arg in ipairs(args) do
    if vim.list_contains(nextest_unsupported_flags, arg) then
      table.insert(indexes_to_remove_reverse_order, 1, i)
    end
  end
  for _, i in pairs(indexes_to_remove_reverse_order) do
    table.remove(args, i)
  end
  return args
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
