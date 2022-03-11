import("CoreLibs/object")

-- CONSTANTS
local enemyBaseMoveSpeed = 40
local enemyAcceleration = 5
local enemySize = 12
local enemyGrowSpeed = 2
local enemyHitShrink = 4
local enemyMinSize = 7
-- /CONSTANTS

class("Enemy").extends()

function Enemy:init(pos, dir)
	Enemy.super.init(self)
	self.pos = pos
	self.dir = dir
	self.rect = playdate.geometry.rect.new(pos.x - enemySize / 2, pos.y - enemySize / 2, enemySize, enemySize)
	self.speed = enemyBaseMoveSpeed
end

function Enemy:move()
	self.pos = self.pos + self.dir:scaledBy((deltaTime / 1000) * self.speed)
	self.rect.x = self.pos.x
	self.rect.y = self.pos.y
end

function Enemy:draw()
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(self.rect)
	gfx.setColor(gfx.kColorBlack)
	gfx.setLineWidth(2)
	gfx.drawRect(self.rect)
end

function Enemy:onUpdate()
	self:move()
end
