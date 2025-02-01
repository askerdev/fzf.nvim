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
	}
	for key, val in pairs(default_config) do
		if config[key] == nil then
			config[key] = val
		end
	end
	return config
end

--- @param get_config function
--- @param enter boolean
--- @return { buf: number; win: number; close: function;  }
M.floating_window = function(get_config, enter)
	if enter == nil then
		enter = false
	end

	local res = {}

	res.buf = vim.api.nvim_create_buf(false, true)

	res.win = vim.api.nvim_open_win(res.buf, enter, get_config())

	local close = function()
		vim.api.nvim_win_close(res.win, true)
		vim.api.nvim_buf_delete(res.buf, {
			force = true,
		})
	end

	vim.api.nvim_create_autocmd("VimResized", {
		group = vim.api.nvim_create_augroup("fzf-vim-resized", {}),
		buffer = res.buf,
		callback = function()
			if res == nil or res.win == nil or not vim.api.nvim_win_is_valid(res.win) then
				return
			end
			local status, exception = pcall(function()
				vim.api.nvim_win_set_config(res.win, get_config())
			end)
			if not status then
				vim.notify(vim.inspect(exception))
			end
		end,
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		group = vim.api.nvim_create_augroup("fzf-term-open", {}),
		buffer = res.buf,
		once = true,
		callback = function()
			vim.cmd.startinsert()
		end,
	})

	vim.api.nvim_create_autocmd("TermClose", {
		group = vim.api.nvim_create_augroup("fzf-term-close", {}),
		buffer = res.buf,
		once = true,
		callback = close,
	})

	return res
end

--- @param width string
M.width = function(width)
	return math.floor(vim.o.columns * (tonumber(string.sub(width, 1, #width - 1)) / 100))
end

--- @param height string
M.height = function(height)
	return math.floor(vim.o.lines * (tonumber(string.sub(height, 1, #height - 1)) / 100))
end

--- @param config vim.api.keyset.win_config
--- @return vim.api.keyset.win_config
M.center = function(config)
	config.col = math.floor((vim.o.columns - config.width) / 2)
	config.row = math.floor((vim.o.lines - config.height) / 2 - 1)

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
