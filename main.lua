import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx<const> = playdate.graphics
local ubuntu_mono = gfx.font.new("fonts/ubuntuMONOreg")

-- Base enemy.
local enemy_image = gfx.image.new("images/enemy0")

-- Format: enemy_sprite_<LEVEL>_<INDEX>

local enemy_sprite_1_1 = gfx.sprite.new(enemy_image)
enemy_sprite_1_1:moveTo(280, 208)
enemy_sprite_1_1:setCollideRect(0, 0, enemy_sprite_1_1:getSize())

local enemy_sprite_2_1 = gfx.sprite.new(enemy_image)
enemy_sprite_2_1:moveTo(140, 150)
enemy_sprite_2_1:setCollideRect(0, 0, enemy_sprite_2_1:getSize())

local enemy_sprite_2_2 = gfx.sprite.new(enemy_image)
enemy_sprite_2_2:moveTo(180, 180)
enemy_sprite_2_2:setCollideRect(0, 0, enemy_sprite_2_2:getSize())

local level1 = {
	enemies = { enemy_sprite_1_1 },
	cannonballs = 3,
}

local level2 = {
	enemies = { enemy_sprite_2_1, enemy_sprite_2_2 },
	cannonballs = 1,
}

levels = { level1, level2 }

function load_level(lvl)
	if (lvl > 1) then
		prev_level = levels[lvl - 1]
		playdate.graphics.sprite.removeSprites(prev_level.enemies)
	end
	current_level = levels[lvl]
	for _, enemy in ipairs(current_level.enemies) do
		enemy:add()
	end
	cannonball_limit = current_level.cannonballs
	level_enemies = #current_level.enemies
end

local arc_image = gfx.image.new(60, 60)
gfx.pushContext(arc_image)
gfx.drawArc(0, 60, 60, 0, 90)
gfx.popContext()
local sprite_arc = gfx.sprite.new(arc_image)
sprite_arc:moveTo(30, 210)
sprite_arc:add()

local image_ball = gfx.image.new("images/ball")
local sprite_ball = gfx.sprite.new(image_ball)
sprite_ball:moveTo(10, 230)
sprite_ball:setCollideRect(0, 0, sprite_ball:getSize())
sprite_ball:add()

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

local aim_image = gfx.image.new(400, 240)
gfx.pushContext(aim_image)
gfx.drawLine(0, 0, 400, 240)
gfx.popContext()
local aim_sprite = gfx.sprite.new(aim_image)
aim_sprite:moveTo(200, 120)
aim_sprite:add()

local background_image = gfx.image.new("images/background")
assert(background_image)

gfx.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
		gfx.setClipRect(x, y, width, height) -- let's only draw the part of the screen that's dirty
		background_image:draw(0, 0)
		gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
	end
)

-- local tester = playdate.sound.sampleplayer.new("music/cannon_in_D")
-- tester:play()

-- Background music
-- background_music = playdate.sound.fileplayer.new()
-- background_music:load("music/level1int")
-- background_music:play()

local MAX_VELOCITY = 8.0

local last_aim_angle = -1
local last_aim_velocity = -1

function updatevelocity(velocity)
	if (velocity == last_aim_velocity) then
		return
	end
	new_velocity_image = gfx.image.new(400, 16)
	gfx.pushContext(new_velocity_image)
	local scaled_velocity = (velocity / MAX_VELOCITY) * 394
	gfx.setLineWidth(13)
	gfx.drawLine(6, 8, scaled_velocity + 6, 8)
	gfx.setLineWidth(1)
	-- Complete.
	gfx.popContext()
	meter_line_sprite:setImage(new_velocity_image)
end

function updateaim(angle)
	if (angle == last_aim_angle) then
		return
	end
	local x = 240 * math.tan(math.rad(angle))
	new_aim_image = gfx.image.new(400, 240)
	gfx.pushContext(new_aim_image)
	-- Draw the thin line for the aim.
	gfx.drawLine(10, 230, x + 10, 0)
	-- Complete.
	gfx.popContext()
	aim_sprite:setImage(new_aim_image)
	last_aim_angle = angle
end

function calc_movement(velocity, angle)
	local x = velocity * math.cos(math.rad(angle))
	local y = velocity * math.sin(math.rad(angle))
	return x, y
end

-- State.
local frame = 0
local STATE_TITLE = "title"
local STATE_GAME_OVER = "game_over"
local STATE_SET_ANGLE = "set_angle"
local STATE_SET_VELOCITY = "set_velocity"
local STATE_FIRING = "firing"
local state = STATE_TITLE

-- Player weapon.
local angle = 45.0
local velocity = 0.0
local cannonballs_used = 0
local defeated_enemies = 0

-- Level.
local level = 1
function playdate.update()
	if (state == STATE_TITLE) then
		load_level(level)
		change_state(STATE_SET_ANGLE)
		return
	end
	if (state == STATE_GAME_OVER) then
		return
	end
	if (state == STATE_SET_ANGLE) then
		angle = playdate.getCrankPosition()
		angle = angle / 4
		updateaim(angle)
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
			change_state(STATE_FIRING)
			return
		end
	end
	if (state == STATE_FIRING) then
		for _, overlapsprite in pairs(sprite_ball:overlappingSprites()) do
			overlapsprite:remove()
			defeated_enemies = defeated_enemies + 1
		end
		frame = frame + 1
		local gravity = 0.14
		local x, y = calc_movement(velocity, 90.0 - angle)
		y = y - gravity * (frame / 2.0)
		sprite_ball:moveTo(sprite_ball.x + x, sprite_ball.y - y)
		if (sprite_ball.y > 250) then
			sprite_ball:moveTo(10, 230)
			frame = 0
			velocity = 0.0
			if (cannonballs_used < cannonball_limit and defeated_enemies >= level_enemies) then
				print("level complete")
				level = level + 1
				cannonballs_used = 0
				defeated_enemies = 0
				change_state(STATE_SET_ANGLE)
				load_level(level)
				return
			elseif (cannonballs_used >= cannonball_limit and defeated_enemies < level_enemies) then
				change_state(STATE_GAME_OVER)
				return
			end
			change_state(STATE_SET_ANGLE)
			cannonballs_used = cannonballs_used + 1
		end
	end
	gfx.sprite.update()
	playdate.timer.updateTimers()
end

function change_state(new_state)
	print(new_state)
	state = new_state
	gfx.sprite.update()
	playdate.timer.updateTimers()
end
