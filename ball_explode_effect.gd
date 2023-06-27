extends AnimatedSprite2D

signal ended(t :Team.Type)

var team :Team.Type = Team.Type.NONE

func spawn(t :Team.Type, p :Vector2):
	team = t
	position = p
	play("default")

func _on_animation_finished() -> void:
	emit_signal("ended",team)
	queue_free()
