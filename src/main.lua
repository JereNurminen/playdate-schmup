import("CoreLibs/object")
import("CoreLibs/timer")
import("CoreLibs/ui")

import("enemy")
import("bullet")

-- GLOBALS
deltaTime = 0
gfx = playdate.graphics

local screenSize <const> = playdate.geometry.vector2D.new(400, 240)
local screenCenter <const> = screenSize / 2
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

local enemies = {}
local enemySpawnCooldown = 3000
local enemyBaseMoveSpeed = 10
local enemyAcceleration = 5
local enemySize = 8
local enemyGrowSpeed = 2
local enemyHitShrink = 4
local enemyMinSize = 7
local enemySpawnMargin = 10
local enemyRotationSpeed = 90

local delayAfterGameOver = 2000

local entities = {}

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
	print("new enemy at ", pos.x, pos.y)
	table.insert(
		entities,
		Enemy(pos, (playerPosition - pos):normalized())
	)
	playdate.timer.performAfterDelay(enemySpawnCooldown, spawnEnemy)
end

function moveEnemies()
	for i, enemy in ipairs(enemies) do
		local moveVector = enemy.direction:scaledBy((deltaTime / 1000) * enemy.speed)
		local newPos = enemies[i].pos + moveVector 
		enemies[i].pos = newPos
		enemies[i].rect.x = newPos.x
		enemies[i].rect.y = newPos.y
		if
			(newPos.x > screenSize.x or newPos.x < 0) or
			(newPos.y > screenSize.y or newPos.y < 0) then
				enemies[i].direction = (playerPosition - newPos):normalized()
				enemies[i].speed += enemyAcceleration
				enemies[i].rect.height += enemyGrowSpeed
				enemies[i].rect.width += enemyGrowSpeed
		end
		if ship:intersects(enemy.rect:toPolygon()) then
			gameOver()
		end
	end
end

function drawEnemies()
	for i, enemy in ipairs(enemies) do
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(enemy.rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.drawRect(enemy.rect)
	end
end

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

function startGame()
	gameHasStarted = true
	shoot()
	spawnEnemy()
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
		entities,
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

function moveBullets()
	for i, bullet in ipairs(bullets) do
		local moveVector = bullet.direction:normalized():scaledBy((deltaTime / 1000) * playerBulletSpeed)
		bullets[i].pos += moveVector 
		if (bullet.pos.x > screenSize.x or bullet.pos.x < 0) or (bullet.pos.y > screenSize.y or bullet.pos.y < 0) then
			table.remove(bullets, i)
		end 
		for j, enemy in ipairs(enemies) do
			if enemy.rect:containsPoint(playdate.geometry.point.new(bullet.pos:unpack())) then
				local newEnemyWidth = enemy.rect.width - enemyHitShrink
				if newEnemyWidth < enemyMinSize then
					table.remove(enemies, j)
				else
					enemies[j].rect.width = newEnemyWidth
					enemies[j].rect.height = newEnemyWidth
				end
				table.remove(bullets, i)
			end
		end
	end
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
		for i, e in ipairs(entities) do
			e:onUpdate()
			e:draw()
		end
		moveShip()
		drawShip(playerPosition.x, playerPosition.y, 20)
		-- moveBullets()
		-- drawBullets()
		-- drawEnemies()
		-- moveEnemies()
		lastFrameTime = playdate.getCurrentTimeMilliseconds()
	end
end

math.randomseed(playdate.getCurrentTimeMilliseconds())
init()