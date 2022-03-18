class("Bullet").extends(MovingEntity)

function Bullet:init(pos, dir, speed, size)
	Bullet.super.init(self, pos, dir, speed, size)
end

function Bullet:draw()
	if self.active then
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(self.pos.x - self.size / 2, self.pos.y, self.size, self.size)
	end
end

function Bullet:checkCollisions()
	for i, enemy in ipairs(entities.enemies) do
		if enemy.rect:containsPoint(self.pos:unpack()) then
			self:kill()
			enemy:onHit()
		end
	end
end

function Bullet:onOutOfBounds()
	self:kill()
end

function Bullet:onUpdate()
	if self.active then
		self:move()
		self:checkCollisions()
		self:checkOutOfBounds()
	end
end
