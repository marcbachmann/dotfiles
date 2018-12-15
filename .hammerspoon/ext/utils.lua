local module = {}

module.serialize = function(t)
  local serializedValues = {}
  local value, serializedValue
  for i=1,#t do
    value = t[i]
    serializedValue = type(value)=='table' and serialize(value) or value
    table.insert(serializedValues, serializedValue)
  end
  return string.format("{ %s }", table.concat(serializedValues, ', ') )
end

module.nextElement = function(tbl, key, offset)
  for i=1, #tbl, 1 do
    if tbl[i] == key then
      return tbl[i + offset]
    end
  end
end


return module
