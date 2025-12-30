local test = require('rustaceanvim.test')

---@param fixture string
local function run_golden_test_cargo(fixture)
  ---@diagnostic disable-next-line: missing-fields
  local results = test.parse_cargo_test_diagnostics(fixture, 0)
  assert.same({
    {
      bufnr = 0,
      lnum = 1,
      end_lnum = 1,
      col = 5,
      end_col = 5,
      message = [[
thread 'test_external_fail2' (42656) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
]],
      severity = vim.diagnostic.severity.ERROR,
      source = 'rustaceanvim',
      test_id = 'test_external_fail2',
    },
    {
      bufnr = 0,
      lnum = 1,
      end_lnum = 1,
      col = 5,
      end_col = 5,
      message = [[
thread 'test_external_fail' (42655) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
]],
      severity = vim.diagnostic.severity.ERROR,
      source = 'rustaceanvim',
      test_id = 'test_external_fail',
    },
  }, results)
end

local function run_golden_test_nextest(fixture)
  ---@diagnostic disable-next-line: missing-fields
  local results = test.parse_nextest_diagnostics(fixture, 0)
  assert.same({
    {
      bufnr = 0,
      lnum = 1,
      end_lnum = 1,
      col = 5,
      end_col = 5,
      message = [[

thread 'test_external_fail' (45122) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
]],
      severity = vim.diagnostic.severity.ERROR,
      source = 'rustaceanvim',
      test_id = 'test_external_fail',
    },
    {
      bufnr = 0,
      lnum = 1,
      end_lnum = 1,
      col = 5,
      end_col = 5,
      message = [[

thread 'test_external_fail2' (45125) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
]],
      severity = vim.diagnostic.severity.ERROR,
      source = 'rustaceanvim',
      test_id = 'test_external_fail2',
    },
  }, results)
end

describe('rustaceanvim.test', function()
  describe('parse_cargo_test_diagnostics can handle thread id', function()
    it('passing tests in cargo output with thread id', function()
      --
      local fixture = [[
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running unittests src/lib.rs (target/debug/deps/rustaceanvim-d72a96855df9f85e)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running tests/repro.rs (target/debug/deps/repro-aee55062c6fe3ab3)

running 4 tests
test test_external_fail ... FAILED
test test_ok ... ok
test test_external_fail2 ... FAILED
test test_ok2 ... ok

failures:

---- test_external_fail2 stdout ----

thread 'test_external_fail2' (42656) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2

---- test_external_fail stdout ----

thread 'test_external_fail' (42655) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace


failures:
    test_external_fail
    test_external_fail2

test result: FAILED. 2 passed; 2 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

error: test failed, to rerun pass `--test repro`
]]
      run_golden_test_cargo(fixture)
    end)
  end)
  describe('parse_cargo_nextest_diagnostics', function()
    it('passing tests in cargo-nextest junit output', function()
      local fixture = [[
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="nextest-run" tests="4" failures="2" errors="0" uuid="bbaf626a-73b7-4a3b-b3f1-7260f1dc8264" timestamp="2025-11-30T12:42:55.985+09:00" time="0.005">
    <testsuite name="rustaceanvim::repro" tests="4" disabled="0" errors="0" failures="2">
        <testcase name="test_external_fail" classname="rustaceanvim::repro" timestamp="2025-11-30T12:42:55.986+09:00" time="0.002">
            <failure message="thread &apos;test_external_fail&apos; (45122) panicked at src/lib.rs:2:5" type="test failure with exit code 101">thread &apos;test_external_fail&apos; (45122) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace</failure>
            <system-out>
running 1 test
test test_external_fail ... FAILED

failures:

failures:
    test_external_fail

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

</system-out>
            <system-err>
thread &apos;test_external_fail&apos; (45122) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
</system-err>
        </testcase>
        <testcase name="test_ok2" classname="rustaceanvim::repro" timestamp="2025-11-30T12:42:55.986+09:00" time="0.002">
            <system-out>
running 1 test
test test_ok2 ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

</system-out>
            <system-err></system-err>
        </testcase>
        <testcase name="test_ok" classname="rustaceanvim::repro" timestamp="2025-11-30T12:42:55.986+09:00" time="0.002">
            <system-out>
running 1 test
test test_ok ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

</system-out>
            <system-err></system-err>
        </testcase>
        <testcase name="test_external_fail2" classname="rustaceanvim::repro" timestamp="2025-11-30T12:42:55.986+09:00" time="0.003">
            <failure message="thread &apos;test_external_fail2&apos; (45125) panicked at src/lib.rs:2:5" type="test failure with exit code 101">thread &apos;test_external_fail2&apos; (45125) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace</failure>
            <system-out>
running 1 test
test test_external_fail2 ... FAILED

failures:

failures:
    test_external_fail2

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

</system-out>
            <system-err>
thread &apos;test_external_fail2&apos; (45125) panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
</system-err>
        </testcase>
    </testsuite>
</testsuites>
]]
      run_golden_test_nextest(fixture)
    end)
  end)
end)
