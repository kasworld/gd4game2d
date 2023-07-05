extends Sprite2D

signal ended(t :Team.Type)

var team :Team.Type = Team.Type.NONE

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	team = t
	position = p

func _process(delta: float) -> void:
	self_modulate.a -=0.1
	scale *= 1.2

func _on_timer_timeout() -> void:
	emit_signal("ended",team)
	queue_free()
