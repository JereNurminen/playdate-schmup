local gfx <const> = playdate.graphics
local screenCenter <const> = {}
screenCenter.x = 200
screenCenter.y = 120
local playerSpeed <const> = 50
local inputs = {}

local lastFrameTime = 0
local deltaTime = 0

local playerMovement = {}
local playerPosition = screenCenter

function drawShip(x, y, size)
	local halfSize = size / 2
	gfx.setColor(gfx.kColorBlack)
	gfx.fillPolygon(
		x,
		y - halfSize,
		x - halfSize,
		y + halfSize,
		x,
		y + halfSize / 2,
		x + halfSize,
		y + halfSize
	)
end

function updateInputs()
	inputs.up = playdate.buttonIsPressed(playdate.kButtonUp)
	inputs.down = playdate.buttonIsPressed(playdate.kButtonDown)
	inputs.left = playdate.buttonIsPressed(playdate.kButtonLeft)
	inputs.right = playdate.buttonIsPressed(playdate.kButtonRight)
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
	
	movement = playdate.geometry.vector2D.new(x, y):normalized():scaledBy(deltaTime / 1000 * playerSpeed)
	
	playerPosition.y += movement.y
	playerPosition.x += movement.x
end

function playdate.update(arg, ...)
	deltaTime = playdate.getCurrentTimeMilliseconds() - lastFrameTime
	updateInputs()
	moveShip()
	gfx.clear()
	drawShip(playerPosition.x, playerPosition.y, 20)
	lastFrameTime = playdate.getCurrentTimeMilliseconds()
end
