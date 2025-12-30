local overrides = require('rustaceanvim.overrides')
local maybe_nextest_transform = overrides.maybe_nextest_transform

local orig_vim_fn_executable = vim.fn.executable

setup(function()
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.executable = function(expr)
    if expr == 'cargo-nextest' then
      return 1
    end
    return orig_vim_fn_executable(expr)
  end
end)

teardown(function()
  vim.fn.executable = orig_vim_fn_executable
end)

describe('nextest', function()
  describe('`cargo test <target>` -> `cargo nextest run <target>`', function()
    local args = {
      'test',
      'tests::my_test_target',
    }
    local transformed_args = maybe_nextest_transform(args)
    assert.are.same({
      'nextest',
      'run',
      'tests::my_test_target',
    }, { unpack(transformed_args, 1, 3) })
  end)
  describe('`-- --exact <target>` -> `-- <target>`', function()
    local args = {
      'test',
      'tests::my_test_target',
      '--',
      'foo',
      '--exact',
    }
    local transformed_args = maybe_nextest_transform(args)
    assert.False(vim.tbl_contains(transformed_args, '--exact'))
    assert.True(vim.tbl_contains(transformed_args, 'foo'))
  end)
  describe('removes unsupported `--show-output`', function()
    local args = {
      'test',
      'tests::my_test_target',
      '--',
      '--show-output',
    }
    local transformed_args = maybe_nextest_transform(args)
    assert.False(vim.tbl_contains(transformed_args, '--show-output'))
  end)
  describe('`-- foo --nocapture` -> `-- foo`', function()
    local args = {
      'test',
      'tests::my_test_target',
      '--',
      'foo',
      '--nocapture',
    }
    local transformed_args = maybe_nextest_transform(args)
    assert.are.same({
      'nextest',
      'run',
      'tests::my_test_target',
      '--profile',
      'rustaceanvim',
      '--config-file',
      require('rustaceanvim.cache').nextest_config_path(),
      '--',
      'foo',
    }, transformed_args)
  end)
  describe('`-- --nocapture` -> ``', function()
    local args = {
      'test',
      'tests::my_test_target',
      '--',
      '--nocapture',
    }
    local transformed_args = maybe_nextest_transform(args)
    assert.are.same({
      'nextest',
      'run',
      'tests::my_test_target',
      '--profile',
      'rustaceanvim',
      '--config-file',
      require('rustaceanvim.cache').nextest_config_path(),
    }, transformed_args)
  end)
end)
