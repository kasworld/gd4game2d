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
	$Sprite2D.self_modulate.r = 1-(sin(tm*PI/53+alpha_base*2*PI)+1)/20
	$Sprite2D.self_modulate.g = 1-(sin(tm*PI/51+alpha_base*2*PI)+1)/20
	$Sprite2D.self_modulate.b = 1-(sin(tm*PI/47+alpha_base*2*PI)+1)/20
	$Sprite2D.scale = Vector2.ONE * (sin(tm*PI/59+scale_base*2*PI)/3+1)

func _physics_process(delta: float) -> void:
	var bn = Bounce.bounce(position,velocity,vp_size,BOUNCE_RADIUS)
	position = bn.position
	velocity = bn.velocity

	position += velocity * delta
	velocity = velocity.limit_length(SPEED_LIMIT)
	rotate(rotate_rad*delta)

