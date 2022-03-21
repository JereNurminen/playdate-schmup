class("EnemyBullet").extends(MovingEntity)

function EnemyBullet:init(pos, dir, speed, size)
	EnemyBullet.super.init(self, pos, dir, speed, size)
end

function EnemyBullet:draw()
	if self.active then
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(self.pos.x, self.pos.y, self.size, self.size)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.fillRect(self.pos.x, self.pos.y,  self.size, self.size)
	end
end

function EnemyBullet:checkCollisions()
		if entities.player.ship:containsPoint(self.pos:unpack()) then
			self:kill()
			entities.player:die()
		end
end

function EnemyBullet:onOutOfBounds()
	self:kill()
end

function EnemyBullet:onUpdate()
	if self.active then
		self:move()
		self:checkCollisions()
		self:checkOutOfBounds()
	end
end
