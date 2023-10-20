---@mod ferris.executors

---@alias executor_alias 'termopen' | 'quickfix' | 'toggleterm' | 'vimux'

local termopen = require('ferris.executors.termopen')
local quickfix = require('ferris.executors.quickfix')
local toggleterm = require('ferris.executors.toggleterm')
local vimux = require('ferris.executors.vimux')

---@type { [executor_alias]: FerrisExecutor }
local M = {}

---@class FerrisExecutor
---@field execute_command fun(cmd:string, args:string[], cwd:string)

M.termopen = termopen
M.quickfix = quickfix
M.toggleterm = toggleterm
M.vimux = vimux

return M
