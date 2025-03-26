local function mount_game(base_dir)
    print("loading zips under", base_dir)
    for i, v in ipairs({ "background.zip", "foreground.zip", "script.zip", "sound.zip" }) do
        local source = base_dir .. v
        local zip_exists = love.filesystem.getInfo(source) ~= nil
        if zip_exists then
            local destination = base_dir .. v:sub(1, -5) .. '/'
            local mountres = love.filesystem.mountFullPath(
                source:gsub("/documents", love.filesystem.getFullCommonPath("userdocuments")),
                base_dir)
            print("mount res for", source, "to", destination, ":", mountres)
            if (not mountres) then
                error("Failed to mount " .. v .. ". Please check your zip files")
            end
        end
    end
end

return mount_game
