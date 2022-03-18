import("CoreLibs/object")
import("CoreLibs/timer")
import("CoreLibs/ui")

import("moving-entity")
import("enemy")
import("bullet")
import("player")

import("utils")

-- GLOBALS
deltaTime = 0
gfx = playdate.graphics

screenSize = playdate.geometry.vector2D.new(400, 240)
local screenCenter <const> = playdate.geometry.point.new((screenSize / 2):unpack())
unspawnMargin = 20

gameHasStarted = false
gameActive = false

local lastFrameTime = 0

local enemySpawnCooldown = 1500
local enemyBaseMoveSpeed = 60
local enemySize = 16
enemySpawnMargin = 10

local delayAfterGameOver = 2000

inputs = {}
entities = {
	enemies = {},
	bullets = {},
	player = { Player(screenCenter) }
}

function spawnEnemy()
	local pos  = randomScreenEdgePoint()
	table.insert(
		entities.enemies,
		Enemy(pos, (entities.player[1].pos - pos):normalized(), enemyBaseMoveSpeed, enemySize)
	)
	playdate.timer.performAfterDelay(enemySpawnCooldown, spawnEnemy)
end

function updateInputs()
	inputs.up = playdate.buttonIsPressed(playdate.kButtonUp)
	inputs.down = playdate.buttonIsPressed(playdate.kButtonDown)
	inputs.left = playdate.buttonIsPressed(playdate.kButtonLeft)
	inputs.right = playdate.buttonIsPressed(playdate.kButtonRight)
	inputs.crank = playdate.getCrankPosition()
end

function init()
	for i, timer in ipairs(playdate.timer.allTimers()) do
		timer:remove()
	end
	inputs = {}
	gameHasStarted = false
	gameActive = true
	entities = {
		enemies = {},
		bullets = {},
		player = { Player(screenCenter) }
	}
end

function startGame()
	print("game start")
	gameHasStarted = true
	playdate.timer.performAfterDelay(enemySpawnCooldown, spawnEnemy)
end

function gameOver()
	gameActive = false
	gfx.clear()
	playdate.timer.performAfterDelay(delayAfterGameOver, init)
end

function playdate.update(arg, ...)
	playdate.timer.updateTimers()
	updateInputs()
	gfx.clear()
	deltaTime = playdate.getCurrentTimeMilliseconds() - lastFrameTime
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
	lastFrameTime = playdate.getCurrentTimeMilliseconds()
end

math.randomseed(playdate.getCurrentTimeMilliseconds())
init()