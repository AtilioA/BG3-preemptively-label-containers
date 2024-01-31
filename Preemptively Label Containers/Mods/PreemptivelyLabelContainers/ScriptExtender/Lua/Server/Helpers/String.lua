String = {}

-- Character width mapping
local charWidths = {
  -- Punctuation
  [' '] = 1,
  ['-'] = 1,
  ['.'] = 0.8,
  [','] = 0.8,
  ['!'] = 0.8,
  ['?'] = 1.5,
  ['"'] = 1,
  ["'"] = 0.8,
  [':'] = 0.8,
  [';'] = 0.8,
  ['('] = 1,
  [')'] = 1,
  ['*'] = 0.8,
  -- Lowercase
  ['a'] = 1.5,
  ['b'] = 1.5,
  ['c'] = 1.5,
  ['d'] = 1.5,
  ['e'] = 1.5,
  ['f'] = 1.25,
  ['g'] = 1.5,
  ['h'] = 1.5,
  ['i'] = 1,
  ['j'] = 1.5,
  ['k'] = 1.5,
  ['l'] = 1,
  ['m'] = 1.8,
  ['n'] = 1.5,
  ['o'] = 1.8,
  ['p'] = 1.5,
  ['q'] = 1.5,
  ['r'] = 1.25,
  ['s'] = 1.5,
  ['t'] = 1,
  ['u'] = 1.5,
  ['v'] = 1.5,
  ['w'] = 1.8,
  ['x'] = 1.5,
  ['y'] = 1.5,
  ['z'] = 1.5,
  -- Uppercase
  ['A'] = 2.5,
  ['B'] = 2.5,
  ['C'] = 2.5,
  ['D'] = 2.5,
  ['E'] = 2.5,
  ['F'] = 2.5,
  ['G'] = 2.5,
  ['H'] = 2.5,
  ['I'] = 1.5,
  ['J'] = 2.5,
  ['K'] = 2.5,
  ['L'] = 2.5,
  ['M'] = 2.8,
  ['N'] = 2.5,
  ['O'] = 2.5,
  ['P'] = 2.5,
  ['Q'] = 2.5,
  ['R'] = 2.5,
  ['S'] = 2.5,
  ['T'] = 2.5,
  ['U'] = 2.5,
  ['V'] = 2,
  ['W'] = 2.85,
  ['X'] = 2.5,
  ['Y'] = 2.5,
  ['Z'] = 2.5,
  -- Numbers
  ['0'] = 1.5,
  ['1'] = 1.25,
  ['2'] = 1.5,
  ['3'] = 1.5,
  ['4'] = 1.5,
  ['5'] = 1.5,
  ['6'] = 1.5,
  ['7'] = 1.5,
  ['8'] = 1.5,
  ['9'] = 1.5
}

-- Default width for unmapped characters
local defaultCharWidth = 1.5

-- Function to estimate string width based on character widths
local function estimateStringWidth(str)
  local width = 0
  for i = 1, #str do
    local char = str:sub(i, i)
    width = width + (charWidths[char] or defaultCharWidth)
  end
  return width
end

-- Function to pad a string with spaces to match a specified width
function String.PadString(str, targetWidth, newString)
  -- Function to calculate extra padding based on the length of 'newString'
  function calculateExtraPadding(newStringLength)
    local maxLength = 10          -- Length at which extra padding becomes 0
    local maxExtraPaddingSpaces = 14 -- Maximum extra padding in spaces

    if newStringLength >= maxLength then
      return 0
    else
      -- Linearly scale the extra padding from maxExtraPaddingSpaces to 0
      local extraPadding = maxExtraPaddingSpaces * (1 - (newStringLength / maxLength))
      return extraPadding
    end
  end

  local strWidth = estimateStringWidth(str) / 2
  -- if strWidth >= targetWidth then
  --   return str
  -- end

  local spaceWidth = charWidths[' ']
  local extraPaddingSpaces = 0
  if newString then
      local newStringWidth = estimateStringWidth(newString)
      extraPaddingSpaces = calculateExtraPadding(#newString)  -- Get extra padding based on length of newString
      strWidth = strWidth + newStringWidth - (extraPaddingSpaces * spaceWidth)
  end

  local paddingSize = targetWidth - strWidth
  local padding = string.rep(' ', math.floor(paddingSize / spaceWidth))
  return padding .. str
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
