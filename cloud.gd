extends Area2D

const SPEED_LIMIT = 50
const BOUNCE_RADIUS = 40
var velocity :Vector2
var vp :Vector2

func _ready() -> void:
	vp = get_viewport_rect().size
	position = Vector2(randf_range(0,vp.x),randf_range(0,vp.y))
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * SPEED_LIMIT
	rotate(randf()*2*PI)
	if randi_range(0,1) == 0 :
		$Sprite2D.flip_h = true
	if randi_range(0,1) == 0 :
		$Sprite2D.flip_v = true
	$Sprite2D.self_modulate.a = randf()
	$Sprite2D.scale = Vector2.ONE * randf_range(0.3,0.7)

func _physics_process(delta: float) -> void:
	if position.x < BOUNCE_RADIUS :
		position.x = BOUNCE_RADIUS
		velocity.x = abs(velocity.x)
	elif position.x > vp.x - BOUNCE_RADIUS:
		position.x = vp.x - BOUNCE_RADIUS
		velocity.x = -abs(velocity.x)
	if position.y < BOUNCE_RADIUS :
		position.y = BOUNCE_RADIUS
		velocity.y = abs(velocity.y)
	elif position.y > vp.y - BOUNCE_RADIUS:
		position.y = vp.y - BOUNCE_RADIUS
		velocity.y = -abs(velocity.y)

	position += velocity * delta
	velocity = velocity.limit_length(SPEED_LIMIT)

