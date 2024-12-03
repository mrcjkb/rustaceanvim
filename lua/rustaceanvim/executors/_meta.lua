error('Cannot import a meta module')

---@class rustaceanvim.TestExecutor: rustaceanvim.Executor
---@field execute_command fun(cmd:string, args:string[], cwd:string|nil, opts?: rustaceanvim.ExecutorOpts)

---@class rustaceanvim.TestExecutor.Opts: rustaceanvim.ExecutorOpts
---@field runnable? rustaceanvim.RARunnable
