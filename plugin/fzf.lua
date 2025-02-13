local commands = require("fzf")

vim.api.nvim_create_user_command("Fzf", function(opts)
	if commands[opts.args] ~= nil then
		commands[opts.args]()
	end
end, {
	nargs = 1,
	complete = function(arglead)
		local completions = {}
		for key, _ in pairs(commands) do
			table.insert(completions, key)
		end

		return vim.tbl_filter(function(item)
			return vim.startswith(item, arglead)
		end, completions)
	end,
})
