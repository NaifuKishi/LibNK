local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} end
if not LibNK.strings then LibNK.strings = {} end

---------- make global functions local ---------

local stringMatch   = string.match
local stringFind    = string.find
local stringSub     = string.sub
local stringLen     = string.len
local stringGSub    = string.gsub
local stringUpper   = string.upper

local mathFloor     = math.floor
	

---------- library public function block ---------

function LibNK.strings.find(source, pattern)

	if source == nil then return nil end
	
	return stringFind(source, pattern)

end

function LibNK.strings.trim (text)

	return text:match'^()%s*$' and '' or text:match'^%s*(.*%S)'

end

function LibNK.strings.split(text, delimiter)
  
  local result = { }
  local from = 1

  local delim_from, delim_to = stringFind( text, delimiter, from )
  
  while delim_from do
    table.insert( result, stringSub( text, from , delim_from-1 ) )
    from = delim_to + 1
    delim_from, delim_to = stringFind( text, delimiter, from )
  end
  table.insert( result, stringSub( text, from ) )
  return result
  
end

function LibNK.strings.left (value, delimiter)

	local pos = stringFind ( value, delimiter)
	return stringSub ( value, 1, pos-1)

end

function LibNK.strings.leftBack (value, delimiter)

	local temp = LibNK.strings.split(value, delimiter)
	
	local pos = stringFind ( value, temp[#temp])
	return stringSub ( value, 1, pos - stringLen(delimiter))

end

function LibNK.strings.rightBack (value, delimiter)

	local temp = LibNK.strings.split(value, delimiter)
	
	local pos = stringFind ( value, temp[#temp])
	return stringSub ( value, pos)

end

function LibNK.strings.right (value, delimiter, start, plainFlag)

	local pos = stringFind ( value, delimiter, start or 1, plainFlag or true)
	if pos == nil then return value end
	
	return stringSub ( value, pos + stringLen(delimiter))

end

function LibNK.strings.rightRegEx (value, delimiter)
	local pos, len = stringFind ( value, delimiter)
	if pos == nil then return value end
	
	pos = pos + len
	return stringSub ( value, pos)
end

function LibNK.strings.formatNumber (value)
		
	local formatted, k = value, nil
	while true do  
		formatted, k = stringGSub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then break end
	end
	return formatted
	
end

function LibNK.strings.startsWith(value, startValue)
	local compare = stringSub(value, 1, stringLen(startValue))
	return compare == startValue 
end

function LibNK.strings.endsWith(value, endValue)
   return endValue == '' or stringSub(value, - stringLen(endValue)) == endValue
end

function LibNK.strings.Capitalize(inputString)
    -- Split the string into words
    local words = {}
    for word in inputString:gmatch("%S+") do
        table.insert(words, word)
    end

    -- Capitalize the first letter of each word
    for i, word in ipairs(words) do
        if #word > 0 then
            local firstChar = stringSub(word, 1, 1)
            local restOfWord = stringSub(word, 2)
            words[i] = stringUpper(firstChar) .. restOfWord
        end
    end

    -- Join the words back into a single string
    local result = table.concat(words, " ")

    return result
end

function LibNK.strings.formatNumber (number)

  local formatted = tostring(mathFloor(number))
  local k
  while true do
      formatted, k = stringGSub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
      if k == 0 then
          break
      end
  end

  return formatted

end