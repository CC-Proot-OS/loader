local make_package = dofile("sys/boot/load/require.lua").make
local function createShellEnv(dir)
    local env = { shell = shell, multishell = multishell }
    env.require, env.package = make_package(env, dir)
    return env
end

local env = setmetatable(createShellEnv("/rom/programs"), { __index = _ENV })
require = env.require