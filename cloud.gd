extends Area2D

const SPEED_LIMIT = 10.0
const BOUNCE_RADIUS = 10.0
var velocity :Vector2
var vp_size :Vector2
var rotate_rad :float
var alpha_base :float
var scale_base :float
func _ready() -> void:
	vp_size = get_viewport_rect().size
	var image_size = 512
	var size_rate = vp_size.y / (image_size * 4)
	scale = Vector2(size_rate, size_rate)

	position = Vector2(randf_range(0,vp_size.x),randf_range(0,vp_size.y))
	var sp_abs = randfn(SPEED_LIMIT, SPEED_LIMIT/5)
	if sp_abs < SPEED_LIMIT/10:
		sp_abs = SPEED_LIMIT/10
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * sp_abs
	rotate(randf()*2*PI)
	rotate_rad = randfn(0, PI/50)
	alpha_base = randf()
	scale_base = randf()

	if randi_range(0,1) == 0 :
		$Sprite2D.flip_h = true
	if randi_range(0,1) == 0 :
		$Sprite2D.flip_v = true

func _process(_delta: float) -> void:
	var tm = Time.get_unix_time_from_system()
	$Sprite2D.self_modulate.a = (sin(tm*PI/61+alpha_base*2*PI)+1)/2
	$Sprite2D.scale = Vector2.ONE * (sin(tm*PI/59+scale_base*2*PI)/3+1)

func _physics_process(delta: float) -> void:
	if position.x < BOUNCE_RADIUS :
		position.x = BOUNCE_RADIUS
		velocity.x = abs(velocity.x)
	elif position.x > vp_size.x - BOUNCE_RADIUS:
		position.x = vp_size.x - BOUNCE_RADIUS
		velocity.x = -abs(velocity.x)
	if position.y < BOUNCE_RADIUS :
		position.y = BOUNCE_RADIUS
		velocity.y = abs(velocity.y)
	elif position.y > vp_size.y - BOUNCE_RADIUS:
		position.y = vp_size.y - BOUNCE_RADIUS
		velocity.y = -abs(velocity.y)

	position += velocity * delta
	velocity = velocity.limit_length(SPEED_LIMIT)
	rotate(rotate_rad*delta)

