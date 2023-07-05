extends Sprite2D

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	position = p

func _process(delta: float) -> void:
	self_modulate.a -=0.1
	scale *= 1.2

func _on_timer_timeout() -> void:
	queue_free()

