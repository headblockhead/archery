import 'save_load'

function setup_menu(autosave, level, menustate)
    --Add settings to menu
    local menu = playdate.getSystemMenu()
    menu:removeAllMenuItems()
    if (not (menustate == "main")) then
        local menuItem2, error = menu:addMenuItem("to title", function()
            --TODO: conformation dialog for save
            used_cannonballs = 0
            inticks = 0
            outticks = 0
            defeated_enemies = 0
            change_state("title")
            change_menu("enter")
        end)
    end
    local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Auto Save", autosave, function(value)
        saveauto(value)
    end)
    if (not ((level == nil) or (menustate == "main"))) then
        local menuItem, error = menu:addMenuItem("save", function()
            --TODO: conformation dialog for save
            save(level)
        end)
    end
    -- Add image to menu side
    menu_image_bg = playdate.graphics.image.new("images/menu_bg")
    playdate.setMenuImage(menu_image_bg)
end
