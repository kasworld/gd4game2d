class_name Ball extends Area2D

var shield_scene = preload("res://shield.tscn")

signal fire_bullet(c :int, p :Vector2, v :Vector2)
signal ended()

var team :int = -1
var speed_limit := 200
var rotate_dir :float
var velocity :Vector2

func spawn(p :Vector2):
	$ColorBallSprites.frame = randi_range(0,15)
	team = $ColorBallSprites.frame /2
	position = p
	$TimerLife.wait_time = randf() * 30 +1
	$TimerLife.start()
	velocity =  random_vector2(speed_limit)
	rotate_dir = randf_range(-5,5)

func add_shield():
	var sh = shield_scene.instantiate()
	add_child(sh)
	sh.spawn($ColorBallSprites.frame)

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)
	if randf() > 0.99 :
		emit_signal("fire_bullet",$ColorBallSprites.frame, position + velocity/velocity.abs() * $CollisionShape2D.shape.radius*2 , velocity)
	if randf() > 0.99 :
		add_shield()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(speed_limit)

func _on_timer_life_timeout() -> void:
	queue_free()
	emit_signal("ended")

func random_vector2(l :float) ->Vector2:
	return Vector2.ONE.rotated( randf() * 2 * PI ) * l

func line2normal(l ) -> Vector2:
	return (l.b - l.a).orthogonal().normalized()

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Wall:
		var other_shape_owner = area.shape_find_owner(area_shape_index)
		var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
		var nvt = line2normal(other_shape_node.shape)
		velocity = velocity.bounce(nvt)
	elif area is Ball:
		pass
	elif area is Bullet:
		pass
	elif area is Shield:
		pass
