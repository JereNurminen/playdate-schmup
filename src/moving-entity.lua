class("MovingEntity").extends()

function MovingEntity:init(pos, dir, speed, size)
	MovingEntity.super.init(self)
	self.pos = pos
	self.dir = dir
	self.rect = playdate.geometry.rect.new(pos.x - size / 2, pos.y - size / 2, size, size)
	self.speed = speed
	self.size = size
	self.active = true
end

function MovingEntity:move()
	self.pos = self.pos + self.dir:scaledBy((deltaTime / 1000) * self.speed)
	self.rect.x = self.pos.x
	self.rect.y = self.pos.y
end

function MovingEntity:kill()
	self.active = false
end

function MovingEntity:checkOutOfBounds()
	if self.pos.x < -unspawnMargin
	or self.pos.x > screenSize.x + unspawnMargin 
	or self.pos.y < -unspawnMargin
	or self.pos.y > screenSize.y + unspawnMargin then
		self:onOutOfBounds()
	end
end
