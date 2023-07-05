extends Sprite2D

var life_start :float
const SCALE = 1.0

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	position = p
	life_start = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	self_modulate.a = cos(dur*PI/2)
	scale = Vector2( (1 + sin(dur*PI))/2 *SCALE , (1 + cos(dur*PI))/2 * SCALE )
	rotate(delta*PI)

func _on_timer_timeout() -> void:
	queue_free()

