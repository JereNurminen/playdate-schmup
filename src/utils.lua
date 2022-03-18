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
			return playdate.geometry.point.new(x, -enemySpawnMargin)
		end,
		[2] = function()
			return playdate.geometry.point.new(screenSize.x + enemySpawnMargin, y)
		end,
		[3] = function()
			return playdate.geometry.point.new(x, screenSize.y + enemySpawnMargin)
		end,
		[4] = function()
			return playdate.geometry.point.new(-enemySpawnMargin, y)
		end
	}
	
	return directions[dir]()
end
