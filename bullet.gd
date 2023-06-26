class_name Bullet extends Area2D

signal ended()

var speed := 300
var rotate_dir :float
var team :int = -1
var velocity :Vector2
var alive := true

func spawn(c :int,p :Vector2, v :Vector2)->void:
	$AnimatedSprite2D.frame = c
	team = $AnimatedSprite2D.frame /2
	position = p
	velocity = v  / v.abs() * speed
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = 10
	$TimerLife.start()


func end():
	if alive:
		alive = false
		emit_signal("ended")
		queue_free()

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(speed)

func _on_timer_life_timeout() -> void:
	end()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	end()


func _on_area_entered(area: Area2D) -> void:
	if area is Ball:
		if area.team != team:
			end()
	elif area is Bullet:
		if area.team != team:
			end()
	elif area is Shield:
		if area.team != team:
			end()

