import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx<const> = playdate.graphics

local arcimage = gfx.image.new(60, 60)
gfx.pushContext(arcimage)
gfx.drawArc(0, 60, 60, 0, 90)
gfx.popContext()
local arc = gfx.sprite.new(arcimage)
arc:moveTo(30, 210)
arc:add()

local image = gfx.image.new("images/ball.png")
local sprite = gfx.sprite.new(image)
sprite:moveTo(0, 240)
sprite:add()

local aimimage = gfx.image.new(400, 240)
gfx.pushContext(aimimage)
gfx.drawLine(0, 0, 400, 240)
gfx.popContext()
local aim = gfx.sprite.new(aimimage)
aim:moveTo(200, 120)
aim:add()

local lastaimangle = -1

function updateaim(angle)
	if (angle == lastaimangle) then
		return
	end
	local x = 240 * math.tan(math.rad(angle))
	newlineimage = gfx.image.new(400, 240)
	gfx.pushContext(newlineimage)
	gfx.drawLine(0, 240, x, 0)
	gfx.popContext()
	aim:setImage(newlineimage)
	lastaimangle = angle
end

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
		updateaim(angle)
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
		if (sprite.y > 250) then
			sprite:moveTo(0, 240)
			frame = 0
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
