local api = require 'nvim-tree.api'

local M = {}

---Returns true if the given value is a function or a table with a __call metamethod.
---@param val any
---@return boolean
M.is_callable = function(val)
  local t = type(val)
  if t == 'function' then
    return true
  end
  if t == 'table' then
    local mt = getmetatable(val)
    return mt and M.is_callable(mt.__call)
  end
  return false
end

---Check if data appears to be binary by looking for null bytes or non-printable characters
---@param str string The data to check
---@return boolean
M.is_binary = function(str)
  -- Check first 1024 bytes only
  local check_length = math.min(#str, 1024)
  local sample = string.sub(str, 1, check_length)

  -- Look for null bytes
  if string.find(sample, '%z') then
    return true
  end

  -- Count non-printable characters (excluding common whitespace)
  local non_printable = 0
  for i = 1, check_length do
    local byte = string.byte(sample, i)
    if byte < 32 and byte ~= 9 and byte ~= 10 and byte ~= 13 then
      non_printable = non_printable + 1
    end
  end

  -- If more than 10% non-printable characters, consider it binary
  return (non_printable / check_length) > 0.1
end

---Returns true if focus is in a floating window (a picker, an input, a terminal) while the tree
---is open. Entering one keeps the preview, as Snacks pickers keep theirs, so focus can return
---to it (`wincmd p`) once that window closes.
---@return boolean
M.is_float_over_tree = function()
  return vim.api.nvim_win_get_config(0).relative ~= '' and api.tree.is_visible()
end

return M
