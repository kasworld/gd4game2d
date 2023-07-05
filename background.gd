extends ParallaxBackground

const SPEED_LIMIT :float = 150
var velocity :Vector2
var accel :Vector2

func _ready() -> void:
#	$ParallaxLayer.motion_mirroring = $ParallaxLayer/AnimatedSprite2D.texture.get_size()
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * SPEED_LIMIT
	$ParallaxLayer/AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	if randf() < 1.0*delta:
		accel = velocity.rotated( (randf()-0.5) * PI / 2)/4
	velocity += accel
	velocity = velocity.limit_length(SPEED_LIMIT)
	scroll_offset += velocity * delta
