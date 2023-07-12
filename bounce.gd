class_name Bounce

var position :Vector2
var velocity :Vector2
var vp_size :Vector2
var radius :float

func _init(p :Vector2,v :Vector2,vp :Vector2, r :float):
	position = p
	velocity = v
	vp_size = vp
	radius = r
	if position.x < radius :
		position.x = radius
		velocity.x = abs(velocity.x)
	elif position.x > vp_size.x - radius:
		position.x = vp_size.x - radius
		velocity.x = -abs(velocity.x)
	if position.y < radius :
		position.y = radius
		velocity.y = abs(velocity.y)
	elif position.y > vp_size.y - radius:
		position.y = vp_size.y - radius
		velocity.y = -abs(velocity.y)
