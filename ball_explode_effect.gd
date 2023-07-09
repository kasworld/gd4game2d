class_name BallExplodeSprite extends Sprite2D

signal ended(o :BallExplodeSprite)

const LIFE_SEC = 1.0
const SCALE = 1

var team :Team.Type = Team.Type.NONE
var life_start :float

func spawn(t :Team.Type, p :Vector2):
	self_modulate = Team.TeamColor[t]
	team = t
	position = p
	life_start = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		emit_signal("ended",self)
		return

	self_modulate.a = cos(dur*PI/2)
	scale = Vector2( (1 + cos(dur*PI))/2 *SCALE , (1 + sin(dur*PI))/2 * SCALE )
	rotate(delta*PI)
