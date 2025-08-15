local parser = require('rustaceanvim.neotest.parser')

---@param fixture string
---@param is_cargo_test boolean
local function run_golden_test(fixture, is_cargo_test)
  ---@diagnostic disable-next-line: missing-fields
  local results = parser.populate_pass_positions({}, { file = 'test_file.rs', is_cargo_test = is_cargo_test }, fixture)
  assert.same({
    ['test_file.rs::tests::test_ok'] = {
      status = 'passed',
    },
  }, results)
end

describe('rustaceanvim.neotest', function()
  describe('parser', function()
    it('passing tests in cargo output', function()
      --
      local fixture = [[
Finished `test` profile [unoptimized + debuginfo] target(s) in 0.06s
     Running unittests src/main.rs (target/debug/deps/rustaceanvim_460_repro-ec3e570a1613a034)

running 2 tests
test tests::test_ok ... ok
test tests::test_main ... FAILED

successes:

successes:
    tests::test_ok

failures:

---- tests::test_main stdout ----
thread 'tests::test_main' panicked at src/main.rs:9:9:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace


failures:
    tests::test_main

test result: FAILED. 1 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

error: test failed, to rerun pass `-p rustaceanvim-460-repro --bin rustaceanvim-460-repro`
error: 1 target failed:
    `-p rustaceanvim-460-repro --bin rustaceanvim-460-repro`

]]
      run_golden_test(fixture, true)
    end)
    it('passing tests in cargo-nextest junit output', function()
      local fixture = [[
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="nextest-run" tests="2" failures="1" errors="0" uuid="cb64a0e2-5dc1-4ef2-89b3-b3ac1b791b58" timestamp="2025-08-10T21:20:53.300+01:00" time="0.005">
    <testsuite name="rustaceanvim-460-repro::repro" tests="2" disabled="0" errors="0" failures="1">
        <testcase name="test_ok" classname="rustaceanvim-460-repro::repro" timestamp="2025-08-10T21:20:53.301+01:00" time="0.004">
            <system-out>
running 1 test
test test_ok ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

</system-out>
            <system-err></system-err>
        </testcase>
        <testcase name="test_external_fail" classname="rustaceanvim-460-repro::repro" timestamp="2025-08-10T21:20:53.300+01:00" time="0.005">
            <failure type="test failure">thread &apos;test_external_fail&apos; panicked at src/lib.rs:2:5:
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

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

</system-out>
            <system-err>thread &apos;test_external_fail&apos; panicked at src/lib.rs:2:5:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
</system-err>
        </testcase>
    </testsuite>
</testsuites>
]]
      run_golden_test(fixture, false)
    end)
  end)
end)
