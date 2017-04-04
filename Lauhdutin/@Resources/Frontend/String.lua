local STRING = {}

function STRING:StartsWith(asString, asPrefix)
	if asString == nil or asPrefix == nil then
		return false
	end
	return asString:match('^(' .. asPrefix .. '.-)$') ~= nil
end

function STRING:EndsWith(asString, asSuffix)
	if asString == nil or asSuffix == nil then
		return false
	end
	return asString:match('^(.-' .. asSuffix .. ')$') ~= nil
end

function STRING:Trim(asString)
	return asString:match('^%s*(.-)%s*$')
end

function STRING:Split(asString, asPattern)
	return asString:gmatch('([^' .. asPattern .. ']+)')
end

return STRING