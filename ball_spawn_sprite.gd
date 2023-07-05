extends Sprite2D

signal ended(t :Team.Type, p :Vector2)

var team :int
var life_start :float
const SCALE = 1

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	team = t
	position = p
	self_modulate.a = 0
	life_start = Time.get_unix_time_from_system()

func _process(_delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	self_modulate.a = sin(dur*PI/2)
	scale = Vector2( (1 + sin(dur*PI))/2 *SCALE , (1 + sin(dur*PI))/2 * SCALE )

func _on_timer_timeout() -> void:
	emit_signal("ended",team, position)
	queue_free()
