local M = {}

--- @param config vim.api.keyset.win_config?
--- @return vim.api.keyset.win_config
M.default = function(config)
	if config == nil then
		config = {}
	end

	local default_config = {
		relative = "editor",
		width = M.width("70%"),
		height = M.height("75%"),
		style = "minimal",
		border = "rounded",
		noautocmd = true,
	}
	for key, val in pairs(default_config) do
		if config[key] == nil then
			config[key] = val
		end
	end
	return config
end

--- @param config vim.api.keyset.win_config
--- @param enter boolean
--- @return { buf: number; win: number; close: function;  }
M.floating_window = function(config, enter)
	if enter == nil then
		enter = false
	end

	local buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(buf, enter, config)

	local window = { win, buf }

	function window:close()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, {
			force = true,
		})
	end

	return window
end

--- @param width string
M.width = function(width)
	return math.ceil(vim.o.columns * (tonumber(string.sub(width, 1, #width - 1)) / 100))
end

--- @param height string
M.height = function(height)
	return math.ceil(vim.o.lines * (tonumber(string.sub(height, 1, #height - 1)) / 100))
end

--- @param config vim.api.keyset.win_config
--- @return vim.api.keyset.win_config
M.center = function(config)
	config.col = math.min((vim.o.columns - config.width) / 2)
	config.row = math.min((vim.o.lines - config.height) / 2 - 1)

	return config
end

--- @param command string[]
M.exec = function(command)
	local result = vim.system(command, { text = true }):wait()
	return vim.trim(result.stdout)
end

--- @param command string
M.prompt = function(command)
	local co = coroutine.running()
	local file = vim.fn.tempname()
	vim.api.nvim_command("startinsert")
	vim.fn.termopen(command .. " > " .. file, {
		on_exit = function()
			local f = io.open(file, "r")
			if f then
				local stdout = f:read("*all")
				f:close()
				os.remove(file)
				coroutine.resume(co, vim.trim(stdout))
			else
				coroutine.resume(co, "")
			end
		end,
	})
	return coroutine.yield()
end

return M
