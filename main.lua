import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

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

function playdate.update()
	frame += 1
	local angle = playdate.getCrankPosition()
	local velocity = 4.0
	local gravity = 0.1
	local x, y = calc_movement(velocity, 90.0 - angle)
	y -= gravity * (frame / 2.0)
	sprite:moveTo(sprite.x + x, sprite.y - y)
	gfx.sprite.update()
	playdate.timer.updateTimers()
end
