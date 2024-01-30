error('Cannot import a meta module')

---@class RustaceanTestExecutor: RustaceanExecutor
---@field execute_command fun(cmd:string, args:string[], cwd:string|nil, opts?: RustaceanExecutorOpts)

---@class RustaceanTestExecutorOpts: RustaceanExecutorOpts
---@field runnable? RARunnable
