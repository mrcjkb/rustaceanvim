local parser = require('rustaceanvim.neotest.parser')

---@param fixture string
local function run_golden_test_cargo(fixture)
  ---@diagnostic disable-next-line: missing-fields
  local results = parser.populate_pass_positions_cargo_test({}, { file = 'test_file.rs' }, fixture)
  assert.same({
    ['test_file.rs::test_ok'] = {
      status = 'passed',
    },
    ['test_file.rs::test_ok2'] = {
      status = 'passed',
    },
  }, results)
end

local function run_golden_test_nextest(fixture)
  ---@diagnostic disable-next-line: missing-fields
  local results = parser.populate_pass_positions_nextest({}, { file = 'test_file.rs' }, fixture)
  assert.same({
    ['test_file.rs::test_ok'] = {
      status = 'passed',
    },
    ['test_file.rs::test_ok2'] = {
      status = 'passed',
    },
  }, results)
end

describe('rustaceanvim.neotest', function()
  describe('parser', function()
    it('passing tests in cargo output', function()
      --
      local fixture = [[
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running unittests src/lib.rs (target/debug/deps/rustaceanvim_460_repro-9a70619d0810014e)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running tests/repro.rs (target/debug/deps/repro-0338237287f12da7)

running 4 tests
test test_ok ... ok
test test_external_fail2 ... FAILED
test test_external_fail ... FAILED
test test_ok2 ... ok

failures:

---- test_external_fail2 stdout ----

thread 'test_external_fail2' panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2

---- test_external_fail stdout ----

thread 'test_external_fail' panicked at src/lib.rs:2:5:
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
    it('passing tests in cargo-nextest junit output', function()
      local fixture = [[
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="nextest-run" tests="4" failures="2" errors="0" uuid="b884a238-0e2a-499c-b40c-2857d99dbe0f" timestamp="2025-08-15T17:31:44.287+01:00" time="0.006">
    <testsuite name="rustaceanvim-460-repro::repro" tests="4" disabled="0" errors="0" failures="2">
        <testcase name="test_ok" classname="rustaceanvim-460-repro::repro" timestamp="2025-08-15T17:31:44.287+01:00" time="0.005">
            <system-out>
running 1 test
test test_ok ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

</system-out>
            <system-err></system-err>
        </testcase>
        <testcase name="test_external_fail" classname="rustaceanvim-460-repro::repro" timestamp="2025-08-15T17:31:44.287+01:00" time="0.005">
            <failure message="thread &apos;test_external_fail&apos; panicked at src/lib.rs:2:5" type="test failure">thread &apos;test_external_fail&apos; panicked at src/lib.rs:2:5:
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
thread &apos;test_external_fail&apos; panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
</system-err>
        </testcase>
        <testcase name="test_ok2" classname="rustaceanvim-460-repro::repro" timestamp="2025-08-15T17:31:44.287+01:00" time="0.005">
            <system-out>
running 1 test
test test_ok2 ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s

</system-out>
            <system-err></system-err>
        </testcase>
        <testcase name="test_external_fail2" classname="rustaceanvim-460-repro::repro" timestamp="2025-08-15T17:31:44.287+01:00" time="0.005">
            <failure message="thread &apos;test_external_fail2&apos; panicked at src/lib.rs:2:5" type="test failure">thread &apos;test_external_fail2&apos; panicked at src/lib.rs:2:5:
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
thread &apos;test_external_fail2&apos; panicked at src/lib.rs:2:5:
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
