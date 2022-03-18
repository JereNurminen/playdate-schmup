import("CoreLibs/object")
import("CoreLibs/timer")
import("CoreLibs/ui")

import("moving-entity")
import("enemy")
import("bullet")

-- GLOBALS
deltaTime = 0
gfx = playdate.graphics

screenSize = playdate.geometry.vector2D.new(400, 240)
local screenCenter <const> = screenSize / 2
unspawnMargin = 20
local inputs = {}

local gameHasStarted = false
local gameActive = false

local lastFrameTime = 0

local ship
local playerSpeed <const> = 50
local playerMovement = {}
local playerPosition = screenCenter
local playerSpin = 0
local playerNosePos = screenCenter
local playerShootCooldown <const> = 350
local playerShootCooldownWhenMoving <const> = 500

local bullets = {}
local playerBulletSpeed <const> = 150
local playerBulletWidth <const> = 3

local enemySpawnCooldown = 1500
local enemyBaseMoveSpeed = 40
local enemyAcceleration = 5
local enemySize = 16
local enemyGrowSpeed = 2
local enemyHitShrink = 4
local enemyMinSize = 7
local enemySpawnMargin = 10
local enemyRotationSpeed = 90

local delayAfterGameOver = 2000

entities = {
	enemies = {},
	bullets = {}
}
-- / GLOBALS

-- UTILITIES
function vectorFromAngle(angle)
	return playdate.geometry.vector2D.new(math.cos(angle), math.sin(angle)):normalized()
end

function randomScreenEdgePoint()
	local dir = math.random(1, 4)
	local x = math.random(1, screenSize.x)
	local y = math.random(1, screenSize.y)
	
	-- 1/2/3/4 = up/right/down/left
	local directions = {
		[1] = function()
			return playdate.geometry.vector2D.new(x, -enemySpawnMargin)
		end,
		[2] = function()
			return playdate.geometry.vector2D.new(screenSize.x + enemySpawnMargin, y)
		end,
		[3] = function()
			return playdate.geometry.vector2D.new(x, screenSize.y + enemySpawnMargin)
		end,
		[4] = function()
			return playdate.geometry.vector2D.new(-enemySpawnMargin, y)
		end
	}
	
	return directions[dir]()
end

function spawnEnemy()
	local pos  = randomScreenEdgePoint()
	table.insert(
		entities.enemies,
		Enemy(pos, (playerPosition - pos):normalized(), enemyBaseMoveSpeed, enemySize)
	)
	playdate.timer.performAfterDelay(enemySpawnCooldown, spawnEnemy)
end
-- / UTILITIES

function drawShip(x, y, size)
	local halfSize = size / 2
	ship = playdate.geometry.polygon.new(
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
	
	if x == 0 and y == 0 then
		playerIsMoving = false
	else
		if not gameHasStarted then startGame() end
		playerIsMoving = true
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
		entities.bullets,
		Bullet(
			playdate.geometry.vector2D.new(playerNosePos.x, playerNosePos.y),
			(playerNosePos - playerPosition):normalized(),
			playerBulletSpeed,
			playerBulletWidth
		)
	)
	local cooldown = playerIsMoving and playerShootCooldownWhenMoving or playerShootCooldown
	playdate.timer.performAfterDelay(cooldown, shoot)
end

function drawBullets()
	for i, bullet in ipairs(bullets) do
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(bullet.pos.x - playerBulletWidth / 2, bullet.pos.y, playerBulletWidth, playerBulletWidth)
	end
end

function init()
	for i, timer in ipairs(playdate.timer.allTimers()) do
		timer:remove()
	end
	enemies = {}
	bullets = {}
	inputs = {}
	playerPosition = screenCenter
	playerNosePos = screenCenter
	playerSpin = playdate.getCrankPosition()
	gameHasStarted = false
	gameActive = true
end

function startGame()
	gameHasStarted = true
	shoot()
	spawnEnemy()
end

function gameOver()
	gameActive = false
	gfx.clear()
	playdate.timer.performAfterDelay(delayAfterGameOver, init)
end

function playdate.update(arg, ...)
	playdate.timer.updateTimers()
	if gameActive then
		gfx.clear()
		deltaTime = playdate.getCurrentTimeMilliseconds() - lastFrameTime
		updateInputs()
		-- update and draw entities
		for groupName, group in pairs(entities) do
			for i, entity in ipairs(group) do
				if not entity.active then
					table.remove(group, i)
				end
				entity:onUpdate()
				entity:draw()
			end
		end
		moveShip()
		drawShip(playerPosition.x, playerPosition.y, 20)
		lastFrameTime = playdate.getCurrentTimeMilliseconds()
	end
end

math.randomseed(playdate.getCurrentTimeMilliseconds())
init()