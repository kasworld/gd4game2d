class_name Shield extends Area2D

var rotate_dir :float
var team :int = -1
var alive := true

func spawn(c :int):
	$AnimatedSprite2D.frame = c
	team = $AnimatedSprite2D.frame /2
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = randf() * 10  +1
	$TimerLife.start()

func end():
	if alive:
		alive = false
		queue_free()

func _ready() -> void:
	pass # Replace with function body.

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

