local ui = require("fzf.ui")
local cmd = require("fzf.cmd")
local asio = require("fzf.asio")

local M = {}

M.all_files = function()
	if cmd.is_arc_repo() then
		M.arc_files()
	elseif cmd.is_git_repo() then
		M.git_files()
	else
		M.files()
	end
end

M.arc_files = asio.async(function()
	if not cmd.is_arc_repo() then
		print("not an arc repository")
		return
	end

	local w = ui.floating_window(ui.center(ui.default()), true)
	local command = cmd.pipe(cmd.arc.ls_files(), cmd.fzf())
	local stdout = ui.prompt(command)
	w:close()

	if stdout == "" then
		return
	end

	vim.cmd.edit(vim.trim(stdout))
end)

M.git_files = asio.async(function()
	if not cmd.is_git_repo() then
		print("not an git repository")
		return
	end

	local w = ui.floating_window(ui.center(ui.default()), true)
	local command = cmd.pipe(cmd.git.ls_files(), cmd.fzf())
	local stdout = ui.prompt(command)
	w:close()

	if stdout == "" then
		return
	end

	vim.cmd.edit(vim.trim(stdout))
end)

M.files = asio.async(function()
	local w = ui.floating_window(ui.center(ui.default()), true)
	local command = cmd.pipe(cmd.rg.files(), cmd.fzf())
	local stdout = ui.prompt(command)
	w:close()

	if stdout == "" then
		return
	end

	vim.cmd.edit(vim.trim(stdout))
end)

return M
