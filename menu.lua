function setup_menu(autosave)
    --Add settings to menu
    local menu = playdate.getSystemMenu()

    local menuItem, error = menu:addMenuItem("Save now", function()
        save(level)
    end)

    local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Auto Save", autosave, function(value)
        saveauto(value)
    end)

    local menuItem2, error = menu:addMenuItem("Title", function()
        save()
        used_cannonballs = 0
        inticks = 0
        outticks = 0
        defeated_enemies = 0
        change_state(STATE_TITLE)
    end)

    -- Add image to menu side
    menu_image_bg = playdate.graphics.image.new("images/menu_bg")
    playdate.setMenuImage(menu_image_bg)
end
