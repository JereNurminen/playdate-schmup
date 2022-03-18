-- CONSTANTS
local enemyBaseMoveSpeed = 40
local enemyAcceleration = 5
local enemySize = 12
local enemyGrowSpeed = 2
local enemyHitShrink = 4
local enemyMinSize = 7
-- /CONSTANTS

class("Enemy").extends(MovingEntity)

function Enemy:init(pos, dir, speed, size)
	Enemy.super.init(self, pos, dir, speed, size)
	self.spawnPos = pos
end

function Enemy:draw()
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(self.rect)
	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(2)
	gfx.drawRect(self.rect)
end

function Enemy:onHit()
	self:kill()
end

function Enemy:onOutOfBounds()
	self.pos = self.spawnPos
end

function Enemy:onUpdate()
	if self.active then
		self:move()
		self:checkOutOfBounds()
	end
end
