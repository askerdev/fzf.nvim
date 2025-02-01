local M = {}

--- @param command string[]
--- @return string[]
M.exec = function(command)
	local result = vim.system(command, { text = true }):wait()
	return vim.split(vim.trim(result.stdout), "\n")
end

--- @return boolean
M.is_git_repo = function()
	local stdout = M.exec({ "git", "rev-parse", "--is-inside-work-tree", "2>/dev/null" })
	return #stdout >= 1 and stdout[1] == "true"
end

--- @return boolean
M.is_arc_repo = function()
	local stdout = M.exec({ "arc", "rev-parse", "--is-inside-work-tree", "2>/dev/null" })
	return #stdout >= 1 and stdout[1] == "true"
end

--- @param ... string[]
local to_string = function(...)
	return table.concat(..., " ")
end

--- @param default table?
--- @return string[]
local get_args = function(opts, default)
	if opts == nil then
		opts = {}
	end

	if default ~= nil then
		for k, v in pairs(default) do
			if opts[k] == nil then
				opts[k] = v
			end
		end
	end

	local value = {}

	for k, v in pairs(opts) do
		if type(v) ~= "boolean" then
			table.insert(value, "--" .. k .. "=" .. v)
		else
			table.insert(value, "--" .. k)
		end
	end

	return value
end

--- @param opts table?
M.fzf = function(opts)
	local args =
		get_args(opts, { layout = "reverse", height = "100%", ["highlight-line"] = true, info = "inline-right" })
	local cmd = { "fzf" }

	vim.list_extend(cmd, args)

	return to_string(cmd)
end

M.arc = {
	--- @param opts table?
	--- @return string
	ls_files = function(opts)
		local cmd = { "arc", "ls-files" }
		vim.list_extend(cmd, get_args(opts))
		return to_string(cmd)
	end,
}

M.git = {
	--- @param opts table?
	--- @return string
	ls_files = function(opts)
		local cmd = { "git", "ls-files" }
		local default = {
			["exclude-standard"] = true,
		}
		vim.list_extend(cmd, get_args(opts, default))
		return to_string(cmd)
	end,
}

M.rg = {
	--- @param opts table?
	--- @return string
	files = function(opts)
		local cmd = { "rg" }
		vim.list_extend(
			cmd,
			get_args(opts, {
				color = "never",
				files = true,
				glob = "'!{.git,node_modules}'",
			})
		)
		return to_string(cmd)
	end,
}

--- @param ... string
--- @return string
M.pipe = function(...)
	local cmds = { ... }

	return table.concat(cmds, " | ")
end

return M
