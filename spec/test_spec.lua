describe('Parse test results', function()
  local test = require('rustaceanvim.test')
  it('New output', function()
    local fixture = [[
running 1 test
test rocks::dependency::tests::parse_dependency ... FAILED
failures:
    Finished test [unoptimized + debuginfo] target(s) in 0.12s
    Starting 1 test across 2 binaries (17 skipped)
        FAIL [   0.004s] rocks-lib rocks::dependency::tests::parse_dependency
test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 17 filtered out; finis
hed in 0.00s
--- STDERR:              rocks-lib rocks::dependency::tests::parse_dependency ---
thread 'rocks::dependency::tests::parse_dependency' panicked at rocks-lib/src/rocks/dependency.rs:86:64:
called `Result::unwrap()` on an `Err` value: unexpected end of input while parsing min or version number
Location:
    rocks-lib/src/rocks/dependency.rs:62:22
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
]]
    local fname = 'rocks-lib/src/rocks/dependency.rs'
    local diagnostics = test.parse_diagnostics(fname, fixture)
    local expected = {
      {
        lnum = 85,
        col = 64,
        message = [[called `Result::unwrap()` on an `Err` value: unexpected end of input while parsing min or version number
Location:
    rocks-lib/src/rocks/dependency.rs:62:22
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
]],
        severity = vim.diagnostic.severity.ERROR,
        source = 'rustaceanvim',
        test_id = 'rocks::dependency::tests::parse_dependency',
      },
    }
    assert.are.same(expected, diagnostics)
  end)
  it('Legacy output', function()
    local fixture = [[
test tests::failed_math ... FAILED"
failures:

--- tests::failed_math stdout ----
thread 'tests::failed_math' panicked at 'assertion failed: `(left == right)`
 left: `2`,
 right: `3`', src/main.rs:16:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
]]
    local fname = 'src/main.rs'
    local diagnostics = test.parse_diagnostics(fname, fixture)
    local expected = {
      {
        lnum = 15,
        col = 9,
        message = 'assertion failed: `(left == right)`\n left: `2`,\n right: `3`',
        severity = vim.diagnostic.severity.ERROR,
        source = 'rustaceanvim',
        test_id = 'tests::failed_math',
      },
    }
    assert.are.same(expected, diagnostics)
  end)
end)
