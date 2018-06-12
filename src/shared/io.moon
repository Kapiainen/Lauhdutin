return (json) ->
	assert(type(json) == 'table', 'shared.io')
	io.readJSON = (path, pathIsRelative = true) -> return json.decode(io.readFile(path, pathIsRelative))

	io.writeJSON = (relativePath, tbl) ->
		assert(type(tbl) == 'table', 'io.writeJSON')
		return io.writeFile(relativePath, json.encode(tbl))
