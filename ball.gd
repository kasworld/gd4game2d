class_name Ball extends CharacterBody2D

var shield_scene = preload("res://shield.tscn")

signal fire_bullet(c :int, p :Vector2, v :Vector2)
signal ended()

var team :int = -1
var speed_limit := 5
var rotate_dir :float

func spawn(p :Vector2):
	$ColorBallSprites.frame = randi_range(0,15)
	team = $ColorBallSprites.frame /2
	position = p
	$TimerLife.wait_time = randf() * 30 +1
	$TimerLife.start()
	velocity = Vector2(randf_range(-speed_limit,speed_limit),randf_range(-speed_limit,speed_limit))
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
	if $ColorBallSprites.visible :
#		velocity += speed * delta
		velocity = velocity.limit_length(speed_limit)
		var collision_info = move_and_collide(velocity)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())
			velocity = velocity.limit_length(speed_limit)

func _on_timer_life_timeout() -> void:
	queue_free()
	emit_signal("ended")
