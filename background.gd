class_name Background extends ParallaxBackground

const SPEED_LIMIT :float = 20
var velocity :Vector2
var accel :Vector2
var vp_size :Vector2
var bg_state :int

func init_bg(vp :Vector2) -> void:
	vp_size = vp
	init_ani_tile()
	$ColorRect.size = vp_size

var bg_colors = [
	Color.DIM_GRAY,
	Color.DARK_BLUE,
	Color.DARK_GREEN,
	Color.DARK_RED,
	Color.ORANGE.darkened(0.5),
	Color.PURPLE.darkened(0.5),
	Color.YELLOW.darkened(0.5),
]

func toggle_bg():
	bg_state += 1
	bg_state %= bg_colors.size() + 1
	match bg_state:
		0:
			$ParallaxLayer.visible = true
			$ColorRect.visible = false
		_:
			$ParallaxLayer.visible = false
			$ColorRect.visible = true
			$ColorRect.color = bg_colors[bg_state-1]

func init_ani_tile():
	velocity = Vector2.ONE.rotated( randf() * 2 * PI ) * SPEED_LIMIT
	var tilevt = Vector2(128.0, 128.0) # from image
	var sizevt = Vector2( vp_size.y/4,vp_size.y/4)
	var scalevt = Vector2(sizevt.x/tilevt.x, sizevt.y/tilevt.y)
	var mirrorvt = Vector2(
		(int(vp_size.x / sizevt.x) + 1) * sizevt.x,
		(int(vp_size.y / sizevt.y) + 1) * sizevt.y,
		)
	$ParallaxLayer.motion_mirroring = mirrorvt
	var tilecountvt = mirrorvt / sizevt

	var sp_frames = preload("res://background_water.tres")
	sp_frames.set_animation_speed("default",10)

	for x in tilecountvt.x+1:
		for y in tilecountvt.y+1:
			var anisp = AnimatedSprite2D.new()
			anisp.sprite_frames = sp_frames
			$ParallaxLayer.add_child(anisp)
			anisp.scale = scalevt
			anisp.position = Vector2(sizevt.x*x, sizevt.y*y)
			anisp.play("default")
			anisp.self_modulate = anisp.self_modulate.darkened(0.2)

func _physics_process(delta: float) -> void:
	if bg_state == 0:
		if randf() < 1.0*delta:
			accel = velocity.rotated( (randf()-0.5) * PI / 2)/4
		velocity += accel
		velocity = velocity.limit_length(SPEED_LIMIT)
		scroll_offset += velocity * delta

