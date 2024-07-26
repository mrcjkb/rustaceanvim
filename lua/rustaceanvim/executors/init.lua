---@mod rustaceanvim.executors

local termopen = require('rustaceanvim.executors.termopen')
local quickfix = require('rustaceanvim.executors.quickfix')
local toggleterm = require('rustaceanvim.executors.toggleterm')
local vimux = require('rustaceanvim.executors.vimux')
local background = require('rustaceanvim.executors.background')
local neotest = require('rustaceanvim.executors.neotest')

---@type { [rustaceanvim.test_executor_alias]: rustaceanvim.Executor }
local M = {}

M.termopen = termopen
M.quickfix = quickfix
M.toggleterm = toggleterm
M.vimux = vimux
M.background = background
M.neotest = neotest

return M
