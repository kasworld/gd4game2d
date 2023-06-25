class_name Ball extends CharacterBody2D

var shield_scene = preload("res://shield.tscn")

signal exploded()
signal fire_bullet(c :int, p :Vector2, v :Vector2)
signal ended()

var team :int = -1
var speed_limit := 5
var rotate_dir :float

func spawn():
	$ColorBallSprites.frame = randi_range(0,15)
	stop_move()
	var vprt = get_viewport_rect().size
	position.x =  randf_range(0,vprt.x)
	position.y =  randf_range(0,vprt.y)
	$ExplodeSprite.visible = false
	$SpawnSprite.visible = true
	$SpawnSprite.play_backwards("default")

func stop_move():
	$CollisionShape2D.visible = false
	velocity = Vector2.ZERO

func explode():
	stop_move()
	$ColorBallSprites.visible = false
	$ExplodeSprite.visible = true
	$ExplodeSprite.play("default")

func ballStart():
	$CollisionShape2D.visible = true
	$SpawnSprite.visible = false
	$TimerLife.wait_time = randf() * 30 +1
	$TimerLife.start()
	$ColorBallSprites.visible = true
	team = $ColorBallSprites.frame /2
	velocity = Vector2(randf_range(-speed_limit,speed_limit),randf_range(-speed_limit,speed_limit))
	rotate_dir = randf_range(-5,5)


func add_shield():
	var sh = shield_scene.instantiate()
	sh.spawn($ColorBallSprites.frame)
	add_child(sh)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
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

func _on_ball_spawn_sprite_animation_finished() -> void:
	ballStart()

func _on_ball_explode_sprite_animation_finished() -> void:
	queue_free()
	emit_signal("ended")

func _on_timer_life_timeout() -> void:
	explode()
