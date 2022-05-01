import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/easing"
import "saver"
-- GFX as a useful shorthand for the playdate's graphics.
local gfx <const> = playdate.graphics

-- Define fonts that will be used.
local ubuntu_mono = gfx.font.new("fonts/ubuntuMONOreg")

-- Define enemy sprites.
local TNT_image = gfx.image.new("images/enemy0")
local Wall_image = gfx.image.new("images/enemy1")
local Box_image = gfx.image.new("images/enemy2")

-- Format: enemy_sprite_<LEVEL>_<INDEX>
-- TAGS:
-- 1 = destrctable
-- 2 = indestructable

-- LEVEL 1
local TNT_enemy_1_1 = gfx.sprite.new(Box_image)
TNT_enemy_1_1:moveTo(280, 208)
TNT_enemy_1_1:setCollideRect(0, 0, TNT_enemy_1_1:getSize())
TNT_enemy_1_1:setTag(1)

local level1 = {
	enemies = { TNT_enemy_1_1 },
	walls = {},
	cannonballs = 5,
}

-- LEVEL 2
local TNT_enemy_2_1 = gfx.sprite.new(TNT_image)
TNT_enemy_2_1:moveTo(280, 208)
TNT_enemy_2_1:setCollideRect(0, 0, TNT_enemy_2_1:getSize())
TNT_enemy_2_1:setTag(1)

local level2 = {
	enemies = { TNT_enemy_2_1 },
	walls = {},
	cannonballs = 5,
}

-- LEVEL 3
local TNT_enemy_3_1 = gfx.sprite.new(TNT_image)
TNT_enemy_3_1:moveTo(380, 208)
TNT_enemy_3_1:setCollideRect(0, 0, TNT_enemy_3_1:getSize())
TNT_enemy_3_1:setTag(1)

local level3 = {
	enemies = { TNT_enemy_3_1 },
	walls = {},
	cannonballs = 5,
}

-- LEVEL 4
local TNT_enemy_4_1 = gfx.sprite.new(Box_image)
TNT_enemy_4_1:moveTo(280, 208)
TNT_enemy_4_1:setCollideRect(0, 0, TNT_enemy_4_1:getSize())
TNT_enemy_4_1:setTag(1)

local wall_enemy_4_2 = gfx.sprite.new(Wall_image)
wall_enemy_4_2:moveTo(180, 170)
wall_enemy_4_2:setCollideRect(0, 0, wall_enemy_4_2:getSize())
wall_enemy_4_2:setTag(2)

local level4 = {
	enemies = { TNT_enemy_4_1 },
	walls = { wall_enemy_4_2 },
	cannonballs = 5,
}

-- LEVEL 5
local TNT_enemy_5_1 = gfx.sprite.new(TNT_image)
TNT_enemy_5_1:moveTo(280, 208)
TNT_enemy_5_1:setCollideRect(0, 0, TNT_enemy_5_1:getSize())
TNT_enemy_5_1:setTag(1)

local wall_enemy_5_2 = gfx.sprite.new(Wall_image)
wall_enemy_5_2:moveTo(180, 170)
wall_enemy_5_2:setCollideRect(0, 0, wall_enemy_5_2:getSize())
wall_enemy_5_2:setTag(2)

local level5 = {
	enemies = { TNT_enemy_5_1 },
	walls = { wall_enemy_5_2 },
	cannonballs = 5,
}

levels = { level1, level2, level3, level4, level5 }


-- Define sound FX players
explosionSFX = playdate.sound.sampleplayer.new("SFX/explosion")
ball_launchSFX = playdate.sound.sampleplayer.new("SFX/ball_launch")
levelcompleteSFX = playdate.sound.sampleplayer.new("SFX/lvl_complete")
ballFallSFX = playdate.sound.sampleplayer.new("SFX/ball_fall")
clickSFX = playdate.sound.sampleplayer.new("SFX/tick")

--Setup the crank
playdate.setCrankSoundsDisabled(true)


-- Debug for loading long-digit levels
local buffer = 0
local bufferindex = 1
function playdate.keyPressed(key)
	if (not key:find("%D")) then
		buffer = buffer + (tonumber(key) / bufferindex)
		bufferindex = bufferindex * 10
	end
	if (key == "P") then
		level = tonumber(buffer * (bufferindex / 10))
		used_cannonballs = 0
		inticks = 0
		outticks = 0
		defeated_enemies = 0
		debug_load_level(tonumber(buffer * (bufferindex / 10)))
		updateballs(used_cannonballs, level_cannonball_limit)
		buffer = 0
		bufferindex = 1
	end
end

function debug_load_level(lvl)
	-- Clear the playfield for the new level
	for _, level in ipairs(levels) do
		playdate.graphics.sprite.removeSprites(level.enemies)
		playdate.graphics.sprite.removeSprites(level.walls)
	end
	-- Load the NEW level
	current_level = levels[lvl]
	for _, enemy in ipairs(current_level.enemies) do
		enemy:add()
	end
	for _, wall in ipairs(current_level.walls) do
		wall:add()
	end
	level_cannonball_limit = current_level.cannonballs
	level_enimies_count = #current_level.enemies
end

-- setup the scene, add the ball and the ui.

-- Game sprites
local arc_image = gfx.image.new(60, 60)

gfx.pushContext(arc_image)

gfx.drawArc(0, 60, 60, 0, 90)

gfx.popContext()

local sprite_arc = gfx.sprite.new(arc_image)
sprite_arc:moveTo(30, 210)
sprite_arc:add()

local image_arrow = gfx.image.new("images/ball")
local sprite_arrow = gfx.sprite.new(image_arrow)
sprite_arrow:moveTo(10, 230)
sprite_arrow:setCollideRect(0, 0, sprite_arrow:getSize())
sprite_arrow:add()

local aim_image = gfx.image.new(400, 240)

gfx.pushContext(aim_image)

gfx.drawLine(0, 0, 400, 240)

gfx.popContext()

local aim_sprite = gfx.sprite.new(aim_image)
aim_sprite:moveTo(200, 120)
aim_sprite:add()

-- UI sprites
local meter_image = gfx.image.new("images/meter")
local sprite_meter = gfx.sprite.new(meter_image)
sprite_meter:setZIndex(2)
sprite_meter:moveTo(200, 8)
sprite_meter:add()

local meter_text_image = gfx.image.new(400, 16)

gfx.pushContext(meter_text_image)

gfx.setImageDrawMode(gfx.kDrawModeInverted)
gfx.setFont(ubuntu_mono)
gfx.drawText("velocity", 0, 0)

gfx.popContext()

local meter_text_sprite = gfx.sprite.new(meter_text_image)
meter_text_sprite:setZIndex(4)
meter_text_sprite:moveTo(207, 8)
meter_text_sprite:add()
gfx.setImageDrawMode(gfx.kDrawModeCopy)

local meter_line_image = gfx.image.new(400, 16)

gfx.pushContext(meter_line_image)

gfx.setLineWidth(13)
gfx.drawLine(6, 8, 100, 8)
gfx.setLineWidth(1)

gfx.popContext()

local meter_line_sprite = gfx.sprite.new(meter_line_image)
meter_line_sprite:setZIndex(3)
meter_line_sprite:moveTo(200, 8)
meter_line_sprite:add()

local ball_text_bg_image = gfx.image.new(40, 16)

gfx.pushContext(ball_text_bg_image)

gfx.fillRect(11, 0, 29, 16)

gfx.popContext()

local ball_text_bg_sprite = gfx.sprite.new(ball_text_bg_image)
ball_text_bg_sprite:setZIndex(4)
ball_text_bg_sprite:moveTo(380, 8)
ball_text_bg_sprite:add()

local ball_text_image = gfx.image.new(40, 16)

gfx.pushContext(ball_text_image)

gfx.setImageDrawMode(gfx.kDrawModeInverted)
gfx.setFont(ubuntu_mono)
gfx.drawText("?/?", 13, 0)

gfx.popContext()

local ball_text_sprite = gfx.sprite.new(ball_text_image)
ball_text_sprite:setZIndex(5)
ball_text_sprite:moveTo(380, 8)
ball_text_sprite:add()
gfx.setImageDrawMode(gfx.kDrawModeCopy)

-- Draw the background
local background_image = gfx.image.new("images/background")
assert(background_image)

gfx.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
	gfx.setClipRect(x, y, width, height)
	background_image:draw(0, 0)
	gfx.clearClipRect()
end
)

local MAX_VELOCITY = 8.0 -- The fastest the ball can be set to go.

-- Default is impossible value to ensure the aim + velocity is updated on first run.
local last_aim_angle = -1
local last_aim_velocity = -1

function updatevelocity(velocity)
	if (velocity == last_aim_velocity) then
		return
	end
	new_velocity_image = gfx.image.new(400, 16)

	gfx.pushContext(new_velocity_image)

	local scaled_velocity = (velocity / MAX_VELOCITY) * 359
	gfx.setLineWidth(13)
	gfx.drawLine(6, 8, scaled_velocity + 6, 8)
	gfx.setLineWidth(1)

	gfx.popContext()

	meter_line_sprite:setImage(new_velocity_image)
	last_aim_velocity = velocity
end

function updateballs(used, max)
	new_ball_text_image = gfx.image.new(40, 16)

	gfx.pushContext(new_ball_text_image)

	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	gfx.setFont(ubuntu_mono)
	gfx.drawText(used .. "/" .. max, 13, 0)

	gfx.popContext()

	ball_text_sprite:setImage(new_ball_text_image)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

local transition_image = gfx.image.new("images/transition")
local transition_sprite = gfx.sprite.new(transition_image)
transition_sprite:setZIndex(15)
transition_sprite:moveTo(800, 120) -- Offscreen

-- Draw a line to show the angle that is being aimed at.
function updateaim(angle)
	-- Don't do the hard maths if we don't need to!
	if (angle == last_aim_angle) then
		return
	end

	local x = 240 * math.tan(math.rad(angle))

	sprite_arrow:setRotation(angle)

	new_aim_image = gfx.image.new(400, 240)

	gfx.pushContext(new_aim_image)

	gfx.drawLine(10, 230, x + 10, 0)

	gfx.popContext()

	aim_sprite:setImage(new_aim_image)

	last_aim_angle = angle
end

function load_level(lvl)
	-- Clear the playfield for the next level
	if (lvl > 1) then
		prev_level = levels[lvl - 1]
		playdate.graphics.sprite.removeSprites(prev_level.enemies)
		playdate.graphics.sprite.removeSprites(prev_level.walls)
	end
	-- Load the next level
	current_level = levels[lvl]
	for _, enemy in ipairs(current_level.enemies) do
		enemy:add()
	end
	for _, wall in ipairs(current_level.walls) do
		wall:add()
	end
	level_cannonball_limit = current_level.cannonballs
	level_enimies_count = #current_level.enemies
end

function calc_movement(velocity, angle)
	local x = velocity * math.cos(math.rad(angle))
	local y = velocity * math.sin(math.rad(angle))
	return x, y
end

-- Ticks are how long the ball has been in the air.
local ticks = 0

-- easing ticks for level transition
local inticks = 0
local outticks = 0

-- State.
local STATE_LEVEL_TRANSITION = "transition"
local STATE_TITLE = "title"
local STATE_GAME_OVER = "game_over"
local STATE_SET_ANGLE = "set_angle"
local STATE_SET_VELOCITY = "set_velocity"
local STATE_FIRING = "firing"
local state = STATE_TITLE

-- Player weapon.
local angle = 45.0
local velocity = 0.0
local used_cannonballs = 0
local defeated_enemies = 0
local projectile_angle = 45.0
local projectile_path = {}

-- Level.
local level = 1

--Add settings to menu
local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem("Save now", function()
	save()
end)

local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Auto Save", true, function(value)
	saveauto(value)
end)

local menuItem2, error = menu:addMenuItem("Title", function()
	save()
	used_cannonballs = 0
	inticks = 0
	outticks = 0
	defeated_enemies = 0
	print("Open Title")
	change_state(STATE_TITLE)
end)

-- Add image to menu side
menu_image_bg = gfx.image.new("images/menu_bg")
playdate.setMenuImage(menu_image_bg)

-- Run on every frame
function playdate.update()
	if (state == STATE_TITLE) then
		--TODO: add title screen
		load_level(level)
		updateballs(used_cannonballs, level_cannonball_limit)
		change_state(STATE_SET_ANGLE)
		return
	end
	if (state == STATE_GAME_OVER) then
		--TODO: add game over screen
		return
	end
	--TODO: add indicator for state ( angle or velocity )
	if (state == STATE_SET_ANGLE) then
		angle = playdate.getCrankPosition()
		angle = angle / 4
		updateaim(angle)
		projectile_angle = angle
		if playdate.buttonJustReleased(playdate.kButtonA) then
			change_state(STATE_SET_VELOCITY)
			return
		end
	end

	if (state == STATE_SET_VELOCITY) then
		velocity = playdate.getCrankPosition() / 45
		updatevelocity(velocity)
		updateaim(angle)
		if playdate.buttonJustReleased(playdate.kButtonA) then
			ball_launchSFX:play()
			change_state(STATE_FIRING)
			return
		end
	end

	if (state == STATE_FIRING) then
		for _, overlapping_sprite in pairs(sprite_arrow:overlappingSprites()) do
			if (overlapping_sprite:getTag() == 1) then
				explosionSFX:play()
				overlapping_sprite:remove()
				defeated_enemies = defeated_enemies + 1
			elseif (overlapping_sprite:getTag() == 2) then
				sprite_arrow.y = 280
			end
		end

		ticks = ticks + 1
		local gravity = 0.14

		local x, y = calc_movement(velocity, 90.0 - angle)
		y = y - gravity * (ticks / 2.0)

		sprite_arrow:moveTo(sprite_arrow.x + x, sprite_arrow.y - y)
		start = { x = 0, y = 240 }
		table.insert(projectile_path, { x = sprite_arrow.x + x, y = sprite_arrow.y + y })
		if #projectile_path > 20 then
			start = projectile_path[1]
			table.remove(projectile_path, 1)
		end
		-- s=o/h c=a/h t=o/a

		xx = sprite_arrow.x - start.x
		yy = sprite_arrow.y - start.y
		projectile_angle = (math.deg(math.atan(yy, xx) + 90)) % 360
		-- The arrow should not be facing backwards. If it is, face it straight down.
		if (projectile_angle > 180 and projectile_angle < 340) then
			projectile_angle = 180
		end
		sprite_arrow:setRotation(projectile_angle)
		sprite_arrow:setCollideRect(0, 0, sprite_arrow:getSize())

		-- If the ball has gone below the screen.
		if (sprite_arrow.y > 250) then
			used_cannonballs = used_cannonballs + 1
			sprite_arrow:setRotation(90)
			sprite_arrow:moveTo(10, 230)
			ticks = 0
			velocity = 0.0

			if (used_cannonballs <= level_cannonball_limit and defeated_enemies >= level_enimies_count) then
				-- If all of the enimies have been defeated. (and within the cannonball limit)
				level = level + 1
				print(level)
				used_cannonballs = 0
				inticks = 0
				outticks = 0
				defeated_enemies = 0
				levelcompleteSFX:play()
				transition_sprite:moveTo(800, 120)
				transition_sprite:add()
				change_state(STATE_LEVEL_TRANSITION)
				return
			elseif (used_cannonballs >= level_cannonball_limit and defeated_enemies < level_enimies_count) then
				-- If the cannonball limit has been reached. (Game Over)
				updateballs(used_cannonballs, level_cannonball_limit)
				change_state(STATE_GAME_OVER)
				ballFallSFX:play()
				return
			end
			-- If there are still cannonballs left (and all of the enimies have not been defeated).
			ballFallSFX:play()
			change_state(STATE_SET_ANGLE)
			updateballs(used_cannonballs, level_cannonball_limit)
		end
	end
	if (state == STATE_LEVEL_TRANSITION) then
		if (inticks < 40) then
			inticks = inticks + 1
			xpos = playdate.easingFunctions.inOutSine(inticks, 800, -600, 40)
			transition_sprite:moveTo(xpos, 120)
		elseif (inticks == 40) then
			-- Load the level
			load_level(level)
			updateballs(used_cannonballs, level_cannonball_limit)
			sprite_arrow:setRotation(90)
			inticks = inticks + 1
		elseif (outticks < 40) then
			outticks = outticks + 1
			xpos = playdate.easingFunctions.inOutSine(outticks, 200, -600, 40)
			transition_sprite:moveTo(xpos, 120)
		else
			change_state(STATE_SET_ANGLE)
			transition_sprite:remove()
			return
		end
	end
	gfx.sprite.update()
	playdate.timer.updateTimers()
end

function change_state(new_state)
	print("State was: " .. state)
	state = new_state
	print("State changed to: " .. new_state)
	print("State is: " .. state)
	gfx.sprite.update()
	playdate.timer.updateTimers()
end
