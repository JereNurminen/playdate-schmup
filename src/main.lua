import("CoreLibs/object")
import("CoreLibs/timer")

-- Redefine math functions to use deg instead of rad
-- (https://www.lua.org/pil/18.html)
--[[
local sin, cos = math.sin, math.cos
local deg, rad = math.deg, math.rad
math.sin = function (x) return sin(rad(x)) end
math.cos = function (x) return deg(cos(x)) end
]]

local gfx <const> = playdate.graphics
local screenCenter <const> = playdate.geometry.vector2D.new(200, 120)
local inputs = {}

local lastFrameTime = 0
local deltaTime = 0

local playerSpeed <const> = 50
local playerMovement = {}
local playerPosition = screenCenter
local playerSpin = 0
local playerNosePos = screenCenter
local playerShootCooldown = 500

local bullets = {}
local playerBulletSpeed <const> = 55

function vectorFromAngle(angle)
	return playdate.geometry.vector2D.new(math.cos(angle), math.sin(angle)):normalized()
end

function drawShip(x, y, size)
	local halfSize = size / 2
	local ship = playdate.geometry.polygon.new(
		x,
		y - halfSize,
		x - halfSize,
		y + halfSize,
		x,
		y + halfSize / 2,
		x + halfSize,
		y + halfSize,
		x,
		y - halfSize
	) * playdate.geometry.affineTransform.new():rotatedBy(playerSpin, x, y)
	
	playerNosePos = playdate.geometry.vector2D.new(ship:getPointAt(1):unpack())
	
	gfx.setLineWidth(2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillPolygon(ship)
end

function updateInputs()
	inputs.up = playdate.buttonIsPressed(playdate.kButtonUp)
	inputs.down = playdate.buttonIsPressed(playdate.kButtonDown)
	inputs.left = playdate.buttonIsPressed(playdate.kButtonLeft)
	inputs.right = playdate.buttonIsPressed(playdate.kButtonRight)
	inputs.crank = playdate.getCrankPosition()
end

function moveShip()
	local x, y
	if inputs.up then
		y = -1
	elseif inputs.down then
		y = 1
	else
		y = 0 
	end	
	
	if inputs.left then
		x = -1
	elseif inputs.right then
		x = 1
	else
		x = 0 
	end	
	
	playerSpin = inputs.crank
	
	movement = playdate.geometry.vector2D.new(x, y)
		:normalized()
		:scaledBy(deltaTime / 1000 * playerSpeed)
	
	playerPosition.y += movement.y
	playerPosition.x += movement.x
end

function shoot()
	table.insert(
		bullets,
		{
			pos = playdate.geometry.vector2D.new(playerNosePos.x, playerNosePos.y),
			direction = playerNosePos - playerPosition
		}
	)
	playdate.timer.performAfterDelay(playerShootCooldown, shoot)
end

function moveBullets()
	for i, bullet in ipairs(bullets) do
		local moveVector = bullet.direction:normalized():scaledBy((deltaTime / 1000) * playerBulletSpeed)
		bullets[i].pos += moveVector 
	end
end

function drawBullets()
	for i, bullet in ipairs(bullets) do
		gfx.setColor(gfx.kColorBlack)
		gfx.drawPixel(bullet.pos.x, bullet.pos.y)
	end
end

function playdate.update(arg, ...)
	deltaTime = playdate.getCurrentTimeMilliseconds() - lastFrameTime
	playdate.timer.updateTimers()
	updateInputs()
	moveShip()
	gfx.clear()
	drawShip(playerPosition.x, playerPosition.y, 20)
	moveBullets()
	drawBullets()
	lastFrameTime = playdate.getCurrentTimeMilliseconds()
end

shoot()