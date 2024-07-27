local parser = require('rustaceanvim.neotest.parser')

---@param fixture string
local function run_golden_test(fixture)
  ---@diagnostic disable-next-line: missing-fields
  local results = parser.populate_pass_positions({}, { file = 'test_file.rs' }, fixture)
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
      run_golden_test(fixture)
    end)
    it('passing tests in cargo-nextest 0.9.7 output', function()
      local fixture = [[
Finished `test` profile [unoptimized + debuginfo] target(s) in 0.05s
    Starting 2 tests across 1 binary (run ID: ddf007aa-59ed-4c8d-8a5a-d5d7f2508c5b, nextest profile: default)
        FAIL [   0.003s] rustaceanvim-460-repro::bin/rustaceanvim-460-repro tests::test_main

--- STDOUT:              rustaceanvim-460-repro::bin/rustaceanvim-460-repro tests::test_main ---

running 1 test
test tests::test_main ... FAILED

failures:

failures:
    tests::test_main

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s


--- STDERR:              rustaceanvim-460-repro::bin/rustaceanvim-460-repro tests::test_main ---
thread 'tests::test_main' panicked at src/main.rs:9:9:
assertion `left == right` failed
  left: 1
 right: 2
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

        PASS [   0.003s] rustaceanvim-460-repro::bin/rustaceanvim-460-repro tests::test_ok
------------
     Summary [   0.004s] 2 tests run: 1 passed, 1 failed, 0 skipped
        FAIL [   0.003s] rustaceanvim-460-repro::bin/rustaceanvim-460-repro tests::test_main
error: test run failed

]]
      run_golden_test(fixture)
    end)
  end)
end)
