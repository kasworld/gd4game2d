extends Node

func bounce(pos :Vector2,vel :Vector2, bound :Rect2, radius :float)->Dictionary:
	var xbounce = 0
	var ybounce = 0
	if pos.x < bound.position.x + radius :
		pos.x = bound.position.x + radius
		vel.x = abs(vel.x)
		xbounce = -1
	elif pos.x > bound.end.x - radius:
		pos.x = bound.end.x - radius
		vel.x = -abs(vel.x)
		xbounce = 1
	if pos.y < bound.position.y + radius :
		pos.y = bound.position.y + radius
		vel.y = abs(vel.y)
		ybounce = -1
	elif pos.y > bound.end.y - radius:
		pos.y = bound.end.y - radius
		vel.y = -abs(vel.y)
		ybounce = 1
	return {
		position = pos,
		velocity = vel,
		xbounce = xbounce,
		ybounce = ybounce,
	}
