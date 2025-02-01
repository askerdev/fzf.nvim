local M = {}

--- @param f function
M.async = function(f)
	return function()
		coroutine.wrap(f)()
	end
end

M.promise = function() end

return M
