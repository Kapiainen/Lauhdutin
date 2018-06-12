parseVDF = (lines, start = 1) ->
	result = {}
	i = start - 1
	while i < #lines
		i += 1
		key = lines[i]\match('^%s*"([^"]+)"%s*$') -- Start of a dictionary
		if key ~= nil
			assert(lines[i + 1]\match('^%s*{%s*$') ~= nil, 'The VDF parser expected "{".')
			tbl, i = parseVDF(lines, i + 2)
			result[key\lower()] = tbl
		else
			key, value = lines[i]\match('^%s*"([^"]+)"%s*"(.-)"%s*$') -- Key-value pair
			if key ~= nil and value ~= nil
				result[key\lower()] = value
			else
				if lines[i]\match('^%s*}%s*$') -- End of a dictionary
					return result, i
				elseif lines[i]\match('^%s*//.*$') -- Comment
					continue
				elseif lines[i]\match('^%s*"#base"%s*"([^"]+)"%s*$')
					continue
				else
					assert(nil, ('The VDF parser encountered unexpected input on line %d: %s.')\format(i, lines[i]))		
	return result, i

return {
	parse: (file) ->
		switch type(file)
			when 'string'
				return parseVDF(file\splitIntoLines())
			when 'table'
				return parseVDF(file)
			else
				assert(nil, ('The VDF parser does not support the "%s" type as its argument.')\format(type(file)))
}
