return function(json)
  assert(type(json) == 'table', 'shared.io')
  io.readJSON = function(path, pathIsRelative)
    if pathIsRelative == nil then
      pathIsRelative = true
    end
    return json.decode(io.readFile(path, pathIsRelative))
  end
  io.writeJSON = function(relativePath, tbl)
    assert(type(tbl) == 'table', 'io.writeJSON')
    return io.writeFile(relativePath, json.encode(tbl))
  end
end
