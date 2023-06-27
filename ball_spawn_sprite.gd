extends AnimatedSprite2D

signal ended(c :int, p :Vector2)

var team_c :int

func spawn(c :int, p :Vector2):
	team_c = c
	position = p
	play_backwards("default")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_finished() -> void:
	emit_signal("ended",team_c, position)
	queue_free()
