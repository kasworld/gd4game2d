extends Area2D

var rotate_dir :float
var team :int = -1


func spawn(c :int):
	$AnimatedSprite2D.frame = c
	team = $AnimatedSprite2D.frame /2
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = randf() * 10  +1
	$TimerLife.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(delta*rotate_dir)
	position = position.rotated(delta*rotate_dir)



func _on_timer_life_timeout() -> void:
	queue_free()
