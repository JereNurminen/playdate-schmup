local wave1 = {
	direction = {0, 1},
	enemies = {
		{ pos = { 20, 0 } },
		{ pos = { 50, 0 } },
		{ pos = { 80, 0 } },
		{ pos = { 110, 0 } },
	}
}

local wave2 = {
	direction = {-0.5, 0.5},
	enemies = {
		{ pos = { 380, -10 } },
		{ pos = { 330, -10 }, delay = 500 },
		{ pos = { 280, -10 }, delay = 1000},
		{ pos = { 380, -10 }, delay = 2000},
		{ pos = { 330, -10 }, delay = 2500},
		{ pos = { 280, -10 }, delay = 3000},
	}
}

local wave3 = {
	direction = {0, 1},
	enemies = {
		{ pos = { 180, 0 }, delay = 500 },
		{ pos = { 200, 0 }, delay = 0 },
		{ pos = { 220, 0 }, delay = 500 },
		{ pos = { 180, 0 }, delay = 2000 },
		{ pos = { 200, 0 }, delay = 1500},
		{ pos = { 220, 0 }, delay = 2000 },
	}
}

local wave4 = {
	direction = {0, 1},
	enemies = {
		{ pos = { 180, 0 } },
		{ pos = { 200, 240 }, direction = {0, -1} },
		{ pos = { 220, 0 } },
		{ pos = { 240, 240 }, direction = {0, -1}  },
	}
}

local debugWave = nil

local enemyShootFrequency = 500
local enemyBulletSpeed = 80
local enemyBulletWidth = 6

function getRandomWave()
	local waves = { wave1, wave2, wave3 }
	return debugWave or waves[math.random(#waves)]
end

class("WaveManager").extends()

function WaveManager:init()
	WaveManager.super.init(self)
	self.active = false
	self.enemies = {}
	self.shootCooldown = enemyShootFrequency
end

function WaveManager:spawnRandomWave()
	local newWave = getRandomWave()
	
	for i, enemy in ipairs(newWave.enemies) do
		playdate.timer.performAfterDelay(
			enemy.delay or 0,
			function()
				table.insert(
					self.enemies,
					{
						enemy = Enemy(
							geo.point.new(table.unpack(enemy.pos)),
							geo.vector2D.new(table.unpack((enemy.direction or newWave.direction)))
						),
						delay = enemy.delay
					}
				)
			end
		)
	end
end

function WaveManager:activate()
	self.active = true
	self:spawnRandomWave()
end

function WaveManager:onUpdate() 
	if self.active then
		local enemiesOnScreen = false
		local enemiesAlive = false
		for i, e in ipairs(self.enemies) do
			e.enemy:onUpdate()
			e.enemy:draw()
			if e.enemy.outOfBounds then
				e.enemy:reset()
			end
			if e.enemy.active then
				enemiesAlive = true
			else
				table.remove(self.enemies, i)
				if #self.enemies == 0 then
					self:spawnRandomWave()
				end
			end
		end
		self.shootCooldown -= deltaTime
		if self.shootCooldown < 0 then
			self.shootCooldown = enemyShootFrequency
			local shootingEnemy = self.enemies[#self.enemies]
			if shootingEnemy then
				table.insert(
					entities.enemyBullets,
					EnemyBullet(
						shootingEnemy.enemy.pos,
						(entities.player.pos - shootingEnemy.enemy.pos):normalized(),
						enemyBulletSpeed,
						enemyBulletWidth
					)
				)
			end
		end
	end
end

function WaveManager:draw()
	for i, e in ipairs(self.enemies) do
		e.enemy:draw()
	end
end
