extends Area2D

const SPEED_LIMIT :float = 50
var velocity :Vector2

func _ready() -> void:
	var vp = get_viewport_rect().size
	position = Vector2(randf_range(0,vp.x),randf_range(0,vp.y))
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * SPEED_LIMIT
	rotate(randf()*2*PI)
	if randi_range(0,1) == 0 :
		$Sprite2D.flip_h = true
	if randi_range(0,1) == 0 :
		$Sprite2D.flip_v = true
	$Sprite2D.self_modulate.a = randf()

func _physics_process(delta: float) -> void:
	var r = $CollisionShape2D.shape.radius
	var vp = get_viewport_rect().size

	if position.x < r :
		position.x = r
		velocity.x = abs(velocity.x)
	elif position.x > vp.x - r:
		position.x = vp.x - r
		velocity.x = -abs(velocity.x)
	if position.y < r :
		position.y = r
		velocity.y = abs(velocity.y)
	elif position.y > vp.y - r:
		position.y = vp.y - r
		velocity.y = -abs(velocity.y)

	position += velocity * delta
	velocity = velocity.limit_length(SPEED_LIMIT)

