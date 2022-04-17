import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx<const> = playdate.graphics

local image = playdate.graphics.image.new("images/thing.png")
local sprite = playdate.graphics.sprite.new(image)
sprite:moveTo(0 + 31, 240 - 31) -- 31 is the width and height of the image
sprite:add()

local image = playdate.graphics.image.new("images/ball.png")
local sprite = playdate.graphics.sprite.new(image)
sprite:moveTo(0, 240)
sprite:add()

function calc_movement(velocity, angle)
	local x = velocity * math.cos(math.rad(angle))
	local y = velocity * math.sin(math.rad(angle))
	return x, y
end

local frame = 0
local STATE_TITLE = "title"
local STATE_SET_ANGLE = "set_angle"
local STATE_SET_VELOCITY = "set_velocity"
local STATE_FIRING = "firing"
local state = STATE_TITLE

-- Player weapon.
local angle = 45.0
local velocity = 1.0

function playdate.update()
	if (state == STATE_TITLE) then
		change_state(STATE_SET_ANGLE)
		return
	end
	if (state == STATE_SET_ANGLE) then
		angle = playdate.getCrankPosition()
		-- TODO: Draw the line.
		if playdate.buttonJustReleased(playdate.kButtonA) then
			change_state(STATE_SET_VELOCITY)
			return
		end
	end
	if (state == STATE_SET_VELOCITY) then
		velocity = playdate.getCrankPosition() / 45
		if playdate.buttonJustReleased(playdate.kButtonA) then
			change_state(STATE_FIRING)
			return
		end
	end
	if (state == STATE_FIRING) then
		frame = frame + 1
		local gravity = 0.1
		local x, y = calc_movement(velocity, 90.0 - angle)
		y = y - gravity * (frame / 2.0)
		sprite:moveTo(sprite.x + x, sprite.y - y)
		if (y > 240) then
			sprite:moveTo(0, 240)
			change_state(STATE_TITLE)
			return
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
