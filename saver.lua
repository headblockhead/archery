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
