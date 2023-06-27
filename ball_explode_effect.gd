extends AnimatedSprite2D

signal ended(c :int)

var team_c :int

func spawn(c :int, p :Vector2):
	team_c = c
	position = p
	play("default")

func _on_animation_finished() -> void:
	emit_signal("ended",team_c)
	queue_free()
