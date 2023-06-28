extends ParallaxBackground

var speed_limit :float = 150
var velocity :Vector2

var sprite_size : Vector2

func _ready() -> void:
	sprite_size = $ParallaxLayer/BGSprite.texture.get_size()
	$ParallaxLayer.motion_mirroring.x = sprite_size.x
	$ParallaxLayer.motion_mirroring.y = sprite_size.y
	velocity = random_vector2(speed_limit)

func random_vector2(l :float) ->Vector2:
	return Vector2.ONE.rotated( randf() * 2 * PI ) * l

func _physics_process(delta: float) -> void:
	if randf() < 1.0*delta:
		velocity += velocity.rotated( (randf()-0.5)*PI/2)
	velocity = velocity.limit_length(speed_limit)
	scroll_offset += velocity * delta
