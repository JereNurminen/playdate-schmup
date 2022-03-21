-- CONSTANTS
local moveSpeed = 60
local size = 12
-- /CONSTANTS

class("Enemy").extends(MovingEntity)

function Enemy:init(pos, dir)
	Enemy.super.init(self, pos, dir, moveSpeed, size)
	self.spawnPos = pos
	self.outOfBounds = false
end

function Enemy:draw()
	if self.active then 
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(self.rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.drawRect(self.rect)
	end
end

function Enemy:onHit()
	self:kill()
end

function Enemy:reset()
	self.pos = self.spawnPos
	self.outOfBounds = false
end

function Enemy:onOutOfBounds()
	self.outOfBounds = true
end

function Enemy:onUpdate()
	if self.active then
		self:move()
		self:checkOutOfBounds()
	end
end
