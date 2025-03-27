local function parse_info(filename)
    local data = {}
    for line in love.filesystem.lines(filename) do
        for k, v in line:gmatch("(%w+)=(.+)") do
            data[k] = v
        end
    end
    pprint(data)
    return data
end
return parse_info
