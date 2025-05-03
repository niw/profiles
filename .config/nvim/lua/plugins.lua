-- This is a modified version of vim-jetpack lua code in `jetpack.vim`.
-- See inline `NOTE:` comments for details.
-- See <https://github.com/tani/vim-jetpack>.

local dict = vim.dict or function(x) return x end
local list = vim.list or function(x) return x end
local function cast(t)
  if type(t) ~= 'table' then
    return t
  end
  local assocp = false
  for k, v in pairs(t) do
    assocp = assocp or type(k) ~= 'number'
    t[k] = cast(v)
  end
  return assocp and dict(t) or list(t)
end

local Jetpack = {}

for _, name in pairs({'begin', 'end', 'add', 'names', 'get', 'tap', 'sync', 'load'}) do
  Jetpack[name] = function(...)
    local result = vim.fn['jetpack#' .. name](...)
    if result == 0 then
      return false
    elseif result == 1 then
      return true
    else
      return result
    end
  end
end
Jetpack.prologue = Jetpack['begin']
Jetpack.epilogue = Jetpack['end']

package.preload['jetpack'] = function()
  return Jetpack
end

local Packer = {
  hook = {},
  option = {},
}

Packer.init = function(option)
  if option.package_root then
    option.package_root = vim.fn.fnamemodify(option.package_root, ":h")
    option.package_root = string.gsub(option.package_root, '\\', '/')
  end
  Packer.option = option
end

local function create_hook(hook_name, pkg_name, value)
  if type(value) == 'function' then
    Packer.hook[hook_name .. '.' .. pkg_name] = value
  else
    Packer.hook[hook_name .. '.' .. pkg_name] = assert((loadstring or load)(value))
  end
  return
    ":lua if require('jetpack').tap('"..pkg_name.."') then "..
    "  require('jetpack.packer').hook['"..hook_name.."."..pkg_name.."']() "..
    "end"
end

local function use(plugin)
  if type(plugin) == 'string' then
    Jetpack.add(plugin)
  else
    local repo = table.remove(plugin, 1)
    if next(plugin) == nil then
      Jetpack.add(repo)
    else
      local name = plugin['as'] or string.gsub(repo, '.*/', '')
      if type(plugin.requires) == 'string' then
        plugin.requires = {plugin.requires}
      end
      for i, req in pairs(plugin.requires or {}) do
        plugin.requires[i] = type(req) == 'string' and req or req['as'] or req[1]
        use(req)
      end
      if plugin.setup then
        plugin.hook_add = create_hook('setup', name, plugin.setup)
      end
      if plugin.config then
        plugin.hook_post_source = create_hook('config', name, plugin.config)
      end
      Jetpack.add(repo, cast(plugin))
    end
  end
end

Packer.startup = function(config)
  Jetpack.prologue(Packer.option.package_root)
  config(use)
  Jetpack.epilogue()
end

Packer.add = function(config)
  Jetpack.prologue(Packer.option.package_root)
  for _, plugin in pairs(config) do
    use(plugin)
  end
  Jetpack.epilogue()
end

package.preload['jetpack.packer'] = function()
  return Packer
end

local Paq = function(config)
  Jetpack.prologue()
  for _, plugin in pairs(config) do
    use(plugin)
  end
  Jetpack.epilogue()
end

package.preload['jetpack.paq'] = function()
  return Paq
end

-- NOTE: Following module code is added.

local M = {
}

function M.init(option)
  Packer.init(option)
end

function M.setup(plugins)
  Jetpack.begin(Packer.option.package_root)
  for _, plugin in pairs(plugins) do
    use(plugin)
  end
  Jetpack['end']()
end

function M.sync()
  for _, name in ipairs(Jetpack.names()) do
    if not Jetpack.tap(name) then
      Jetpack.sync()
      break
    end
  end
end

return M
