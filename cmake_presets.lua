local overseer = require('overseer')
local files = require("overseer.files")

---@type overseer.TemplateFileDefinition
local tmpl = {
  priority = 0,
  params = {
    args = { type = "list", delimiter = " " },
    cwd = { optional = true },
  },
  builder = function(params)
    local cmd = { "cmake" }
    return {
      args = params.args,
      cmd = cmd,
      cwd = params.cwd,
    }
  end,
}

local function find_presets_dir(dir, file)
	local dirs = vim.fs.find(file, { upward = true, type = "file", path = dir, limit = math.huge })
	for _, preset_dirs in ipairs(dirs) do
		if files.exists(preset_dirs) then
			return vim.fs.dirname(preset_dirs)
		end
	end
	return nil
end

local function get_presets_dir(cwd, dir)
	return find_presets_dir(cwd, "CMakeUserPresets.json")
		or find_presets_dir(dir, "CMakeUserPresets.json")
		or find_presets_dir(cwd, "CMakePresets.json")
		or find_presets_dir(dir, "CMakePresets.json")
end

local function get_presets(dir)
	local presets = {
		configure = "Configure",
		build = "Build",
		test = "Test",
		package = "Package",
		workflow = "Workflow"
	}

	local templates = {}
	for preset, preset_name in pairs(presets) do
		local cmd = "cmake " .. dir .. " --list-presets=" .. preset
		local handle = io.popen(cmd)
		local res = handle:read("*a")
		handle:close()

		for name, display_name in string.gmatch(res .. string.char(10), [["(.-)"%s+-%s(.-)]] .. string.char(10)) do
			if name~=nil then
				local args_tbl = {
					configure = { "--preset=" .. name },
					build = { "--build", "--preset=" .. name },
					test = { "--build", "--preset=" .. name },
					package = { "--preset=" .. name },
					workflow = { "--workflow=" .. name }
				}
				local args = args_tbl[preset]
				table.insert(
					templates,
					overseer.wrap_template(
						tmpl,
						{ name = "Cmake " .. preset_name .. " Preset: " .. display_name },
					        { args = args , cwd = dir }
					)
				)
			end

		end

	end

	return templates
end

return {
	generator = function(opts, cb)
		local presets_dir = get_presets_dir(vim.fn.getcwd(), opts.dir)
		assert(presets_dir)

		local presets = get_presets(presets_dir)


		cb(presets)
	end,

	condition = {
		callback = function(search)
			local presets_dir = get_presets_dir(vim.fn.getcwd(), search.dir)
			return presets_dir~=nil
		end,
	},

	cache_key = function(opts)
		return vim.fs.find('CMakePresets.json', { upward = true, type = "file", path = opts.dir} )[1]
	end,
}
