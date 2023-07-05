extends AnimatedSprite2D

signal ended(t :Team.Type, p :Vector2)

var team :int

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	self_modulate.a = 0.4
	team = t
	position = p
	play_backwards("default")

func _on_animation_finished() -> void:
	emit_signal("ended",team, position)
	queue_free()
