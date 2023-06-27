class_name Shield extends Area2D

signal ended(p :Vector2)

var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var alive := true

func spawn(t :Team.Type):
	$AnimatedSprite2D.frame = t*2 + randi_range(0,1)
	team = t
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = randf() * 10  +1
	$TimerLife.start()

func end():
	if alive:
		alive = false
		emit_signal("ended", global_position)
		queue_free()

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)
	position = position.rotated(delta*rotate_dir)

func _on_timer_life_timeout() -> void:
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
	elif area is HommingBullet:
		if area.team != team:
			end()

