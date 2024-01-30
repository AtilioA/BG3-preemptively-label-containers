String = {}

-- Function to pad a string with spaces to match a specified width
---@param str string
---@param width number
---@return string
function String.PadString(str, width)
  -- TODO: pad (Empty) with spaces to match the width of the UI. This will be a bit tricky since the font isn't monospace, but it should be doable.
  -- We can add the number of spaces until the right edge minus the width of the baseName.
  local strWidth = string.len(str)
  if strWidth >= width then
      return str
  end

  local padding = width - strWidth
  -- Remove one extra for each uppercase letter in the string
  padding = padding - string.len(str:gsub("%u", ""))
  local paddedStr = string.rep(" ", padding) .. str
  return paddedStr
end

--- Add parentheses around a string if it does not already have them
function String.AddParentheses(str)
  if string.match(str, "%(.*%)") then
      return str
  else
      return "(" .. str .. ")"
  end
end

-- Remove parentheses around a string if it has them
function String.RemoveParentheses(str)
  return string.gsub(str, "%s*%(%s*(.*)%s*%)", "%1")
end

-- Capitalize the first letter of a string
function String.Capitalize(str)
  return str:gsub("^%l", string.upper)
end

-- Lowercase the first letter of a string
function String.Lowercase(str)
  return str:gsub("^%u", string.lower)
end

return String
