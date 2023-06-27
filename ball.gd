class_name Ball extends Area2D

var shield_scene = preload("res://shield.tscn")

signal fire_bullet(c :int, p :Vector2, v :Vector2)
signal fire_homming(c :int, p :Vector2, dest :Ball)
signal ended(c :int, p :Vector2)

var team :int = -1
var speed_limit :float = 200
var rotate_dir :float
var velocity :Vector2
var alive := true

func get_radius()->float:
	return $CollisionShape2D.shape.radius

func spawn(c :int, p :Vector2):
	c = c % 16
	$ColorBallSprites.frame = c
	team = c / 2
	position = p
	$TimerLife.wait_time = randf() * 300 +1
	$TimerLife.start()
	velocity =  random_vector2()*speed_limit
	rotate_dir = randf_range(-5,5)

func add_shield():
	var sh = shield_scene.instantiate()
	add_child(sh)
	sh.spawn($ColorBallSprites.frame)

func _process(delta: float) -> void:
	var vp = get_viewport_rect()
	if not vp.has_point( position):
		print("invalid ball pos ", position)
		var r = get_radius()
		var clampvt = Vector2(r*3,r*3)
		position = position.clamp(vp.position + clampvt, vp.end - clampvt)
		print("new ball pos ", position)
	rotate(delta*rotate_dir)
	if randf() > 0.9 :
		emit_signal("fire_bullet",$ColorBallSprites.frame, position, random_vector2())
	if randf() > 0.99 :
		emit_signal("fire_homming",$ColorBallSprites.frame, position, self)
	if randf() > 0.95 :
		add_shield()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(speed_limit)

func end():
	if alive:
		alive = false
		emit_signal("ended", $ColorBallSprites.frame, position)
		queue_free()

func _on_timer_life_timeout() -> void:
	end()

func random_vector2() ->Vector2:
	return Vector2.DOWN.rotated( randf() * 2 * PI )

func line2normal(l ) -> Vector2:
	return (l.b - l.a).orthogonal().normalized()

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Wall:
		var other_shape_owner = area.shape_find_owner(area_shape_index)
		var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
		var nvt = line2normal(other_shape_node.shape)
		velocity = velocity.bounce(nvt)
	elif area is Ball:
		if area.team != team:
			end()
	elif area is Bullet:
		if area.team != team:
			end()
	elif area is Shield:
		if area.team != team:
			end()
	elif area is HommingBullet:
		if area.team != team:
			end()

