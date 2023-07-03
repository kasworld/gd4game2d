extends Area2D

const SPEED_LIMIT :float = 50
var velocity :Vector2

func _ready() -> void:
	var vp = get_viewport_rect().size
	position = Vector2(randf_range(0,vp.x),randf_range(0,vp.y))
	$CloudSprites.frame = randi_range(0,3)
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * SPEED_LIMIT
	if randi_range(0,1) == 0 :
		$CloudSprites.flip_h = true

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

