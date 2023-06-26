extends CharacterBody2D

signal ended()

var speed := 10
var rotate_dir :float
var team :int = -1

func spawn(c :int,p :Vector2, v :Vector2)->void:
	$AnimatedSprite2D.frame = c
	team = $AnimatedSprite2D.frame /2
	position = p
	velocity = v  / v.abs() * speed
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = 10
	$TimerLife.start()


func end():
	emit_signal("ended")
	queue_free()

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity)
	if collision_info:
		end()

func _on_timer_life_timeout() -> void:
	end()
