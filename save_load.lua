function load_autosave()
    -- Autosave settings
    local autosave = playdate.datastore.read("autosave")
    if autosave == nil then
        autosave = true
        saveauto(autosave)
    end
    return autosave
end

function load_savegame()
    levelData = playdate.datastore.read("savegame")
    if levelData == nil then
        level = 1
        save(level)
    end
    levelData = playdate.datastore.read("savegame")
    return levelData.current_level
end

function save(level)
    print("Saving...", level)
    local levelData = {
        ["current_level"] = level
    }
    playdate.datastore.write(levelData, "savegame")
end

function saveauto(value)
    print("Autosave: ", value)
    playdate.datastore.write(value, "autosave")
end
