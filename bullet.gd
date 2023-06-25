extends CharacterBody2D

signal exploded()

var speed := 10
var rotate_dir :float
var team :int = -1

func spawn(c :int,p :Vector2, v :Vector2)->void:
	$AnimatedSprite2D.frame = c
	team = $AnimatedSprite2D.frame /2
	position = p
	velocity = v  / v.abs() * speed
	rotate_dir = randf_range(-5,5)
	$CollisionShape2D.visible = true
	$TimerLife.wait_time = 10
	$TimerLife.start()


func explode():
	emit_signal("exploded")
	$AnimatedSprite2D.visible = false
	$BulletExplodeSprite.visible = true
	$BulletExplodeSprite.play_backwards("default")

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity)
	if collision_info:
		explode()

func _on_animated_sprite_2d_animation_finished() -> void:
	pass

func _on_bullet_explode_sprite_animation_finished() -> void:
	queue_free()


func _on_timer_life_timeout() -> void:
	explode()
