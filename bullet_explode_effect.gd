extends AnimatedSprite2D

func spawn(p :Vector2):
	position = p
	play_backwards("default")

func _on_animation_finished() -> void:
	queue_free()
