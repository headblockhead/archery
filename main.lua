import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx<const> = playdate.graphics

local arc_image = gfx.image.new(60, 60)
gfx.pushContext(arc_image)
gfx.drawArc(0, 60, 60, 0, 90)
gfx.popContext()
local sprite_arc = gfx.sprite.new(arc_image)
sprite_arc:moveTo(30, 210)
sprite_arc:add()

local image_ball = gfx.image.new("images/ball.png")
local sprite_ball = gfx.sprite.new(image_ball)
sprite_ball:moveTo(0, 240)
sprite_ball:setCollideRect(0, 0, sprite_ball:getSize())
sprite_ball:add()

local image_enemy = gfx.image.new("images/enemy0.png")
local sprite_enemy = gfx.sprite.new(image_enemy)
sprite_enemy:moveTo(50, 208)
sprite_enemy:setCollideRect(0, 0, sprite_ball:getSize())
sprite_enemy:add()

local aim_image = gfx.image.new(400, 240)
gfx.pushContext(aim_image)
gfx.drawLine(0, 0, 400, 240)
gfx.popContext()
local aim_sprite = gfx.sprite.new(aim_image)
aim_sprite:moveTo(200, 120)
aim_sprite:add()

local background_image = gfx.image.new("images/background.png")
assert(background_image)

gfx.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
		gfx.setClipRect(x, y, width, height) -- let's only draw the part of the screen that's dirty
		background_image:draw(0, 0)
		gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
	end
)

local MAX_VELOCITY = 8.0

local last_aim_angle = -1
local last_aim_velocity = -1

function updateaim(angle, velocity)
	if (angle == last_aim_angle and velocity == last_aim_velocity) then
		return
	end
	local x = 240 * math.tan(math.rad(angle))
	new_aim_image = gfx.image.new(400, 240)
	gfx.pushContext(new_aim_image)
	-- Draw the thin line for the aim.
	gfx.drawLine(0, 240, x, 0)
	-- Draw the thick line for the velocity.
	local percent_velocity = velocity / MAX_VELOCITY
	playdate.graphics.setLineWidth(3)
	gfx.drawLine(0, 240, x * percent_velocity, 240 - (240 * percent_velocity))
	playdate.graphics.setLineWidth(1)
	-- Complete.
	gfx.popContext()
	aim_sprite:setImage(new_aim_image)
	last_aim_angle = angle
	last_aim_velocity = velocity
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
local velocity = 0.0

function playdate.update()
	if (state == STATE_TITLE) then
		change_state(STATE_SET_ANGLE)
		return
	end
	if (state == STATE_SET_ANGLE) then
		angle = playdate.getCrankPosition()
		angle = angle % 90
		updateaim(angle, velocity)
		if playdate.buttonJustReleased(playdate.kButtonA) then
			change_state(STATE_SET_VELOCITY)
			return
		end
	end
	if (state == STATE_SET_VELOCITY) then
		velocity = playdate.getCrankPosition() / 45
		updateaim(angle, velocity)
		if playdate.buttonJustReleased(playdate.kButtonA) then
			change_state(STATE_FIRING)
			return
		end
	end
	if (state == STATE_FIRING) then
		for i, overlapsprite in pairs(sprite_ball:overlappingSprites()) do
			overlapsprite:remove()
		end
		frame = frame + 1
		local gravity = 0.14
		local x, y = calc_movement(velocity, 90.0 - angle)
		y = y - gravity * (frame / 2.0)
		sprite_ball:moveTo(sprite_ball.x + x, sprite_ball.y - y)
		if (sprite_ball.y > 250) then
			sprite_ball:moveTo(0, 240)
			frame = 0
			velocity = 0.0
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
