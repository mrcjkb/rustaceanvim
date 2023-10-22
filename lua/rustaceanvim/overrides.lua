local M = {}

function M.snippet_text_edits_to_text_edits(spe)
  if type(spe) ~= 'table' then
    return
  end
  for _, value in ipairs(spe) do
    if value.newText and value.insertTextFormat then
      -- $0 -> Nothing
      value.newText = string.gsub(value.newText, '%$%d', '')
      -- ${0:_} -> _
      value.newText = string.gsub(value.newText, '%${%d:(.-)}', '%1')
    end
  end
end

-- sanitize_command_for_debugging substitutes the command arguments so it can be used to run a
-- debugger.
--
-- @param command should be a table like: { "run", "--package", "<program>", "--bin", "<program>" }
-- For some reason the endpoint textDocument/hover from rust-analyzer returns
-- cargoArgs = { "run", "--package", "<program>", "--bin", "<program>" } for Debug entry.
-- It doesn't make any sense to run a program before debugging.  Even more the debugging won't run if
-- the program waits some input.  Take a look at rust-analyzer/editors/code/src/toolchain.ts.
function M.sanitize_command_for_debugging(command)
  if command[1] == 'run' then
    command[1] = 'build'
  elseif command[1] == 'test' then
    table.insert(command, 2, '--no-run')
  end
end

return M
