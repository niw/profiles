-- This is a modified, simplified version of vim-jetpack.
-- See <https://github.com/tani/vim-jetpack>.

local M = {
  _hooks = {},
  _options = {},
  _jetpack = {}
}

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

for _, name in pairs({ 'begin', 'end', 'add', 'names', 'get', 'tap', 'sync', 'load' }) do
  M._jetpack[name] = function(...)
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

local function create_hook(hook_name, pkg_name, value)
  if type(value) == 'function' then
    M._hooks[hook_name .. '.' .. pkg_name] = value
  else
    M._hooks[hook_name .. '.' .. pkg_name] = assert((loadstring or load)(value))
  end

  return
    ":lua if require('plugins')._jetpack.tap('" .. pkg_name .. "') then " ..
    "  require('plugins')._hooks['" .. hook_name .. "." .. pkg_name .. "']() " ..
    "end"
end

local function use(plugin)
  if type(plugin) == 'string' then
    M._jetpack.add(plugin)
  else
    local repo = table.remove(plugin, 1)
    if next(plugin) == nil then
      M._jetpack.add(repo)
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
      if plugin.build then
        plugin.build = create_hook('build', name, plugin.build)
      end
      if plugin.config then
        plugin.hook_post_source = create_hook('config', name, plugin.config)
      end
      M._jetpack.add(repo, cast(plugin))
    end
  end
end

function M.init(options)
  if options.package_root then
    options.package_root = vim.fn.fnamemodify(options.package_root, ":h")
    options.package_root = string.gsub(options.package_root, '\\', '/')
  end
  M._options = options
end

function M.setup(plugins)
  M._jetpack.begin(M._options.package_root)
  for _, plugin in pairs(plugins) do
    use(plugin)
  end
  M._jetpack['end']()
end

function M.sync()
  for _, name in ipairs(M._jetpack.names()) do
    if not M._jetpack.tap(name) then
      M._jetpack.sync()
      break
    end
  end
end

return M
