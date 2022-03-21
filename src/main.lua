gfx = playdate.graphics
geo = playdate.geometry

import("CoreLibs/object")
import("CoreLibs/timer")
import("CoreLibs/ui")

import("moving-entity")
import("enemy")
import("bullet")
import("enemy-bullet")
import("player")
import("wave-manager")

import("utils")
import("wave-manager")

-- GLOBALS
deltaTime = 0

screenSize = playdate.geometry.vector2D.new(400, 240)
local screenCenter <const> = playdate.geometry.point.new(
	(screenSize / 2):unpack()
)
unspawnMargin = 20

gameHasStarted = false
gameActive = false

local lastFrameTime = 0

local enemySpawnCooldown = 5000
local enemyBaseMoveSpeed = 60
local enemySize = 16
enemySpawnMargin = 10

local delayAfterGameOver = 2000

inputs = {}
entities = {}

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
		wave = WaveManager(),
		bullets = {},
		player = Player(screenCenter),
		enemyBullets = {}
	}
end

function startGame()
	print("game start")
	gameHasStarted = true
	entities.wave:activate()
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
	for i, bullet in ipairs(entities.bullets) do
		if not bullet.active then
			table.remove(entities.bullets, i)
		end
		bullet:onUpdate()
		bullet:draw()
	end
	for i, bullet in ipairs(entities.enemyBullets) do
		if not bullet.active then
			table.remove(entities.enemyBullets, i)
		end
		bullet:onUpdate()
		bullet:draw()
	end
	entities.player:onUpdate()
	entities.player:draw()
	entities.wave:onUpdate()
	entities.wave:draw()
	
	lastFrameTime = playdate.getCurrentTimeMilliseconds()
end

math.randomseed(playdate.getCurrentTimeMilliseconds())
init()