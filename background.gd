extends ParallaxBackground

const SPEED_LIMIT :float = 100
var velocity :Vector2
var accel :Vector2

func _ready() -> void:
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * SPEED_LIMIT
	var mirrorsize = $ParallaxLayer.motion_mirroring
	var sizewh = 256
	var tilesize = 128
	var sp_frames = preload("res://background_water.tres")
	sp_frames.set_animation_speed("default",10)
	for x in mirrorsize.x/sizewh+1:
		for y in mirrorsize.y/sizewh+1:
			var anisp = AnimatedSprite2D.new()
			anisp.sprite_frames = sp_frames
			$ParallaxLayer.add_child(anisp)
			anisp.scale = Vector2( sizewh/tilesize, sizewh/tilesize)
			anisp.position = Vector2(sizewh*x, sizewh*y)
			anisp.play("default")
			anisp.self_modulate = anisp.self_modulate.darkened(0.2)

func _physics_process(delta: float) -> void:
	if randf() < 1.0*delta:
		accel = velocity.rotated( (randf()-0.5) * PI / 2)/4
	velocity += accel
	velocity = velocity.limit_length(SPEED_LIMIT)
	scroll_offset += velocity * delta
