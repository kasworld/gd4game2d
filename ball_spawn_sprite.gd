extends Sprite2D

signal ended(t :Team.Type, p :Vector2)

var team :int

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	team = t
	position = p
	self_modulate.a = 0

func _process(delta: float) -> void:
	self_modulate.a +=0.05
	scale *= 0.95

func _on_timer_timeout() -> void:
	emit_signal("ended",team, position)
	queue_free()
