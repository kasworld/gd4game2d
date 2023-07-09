class_name HommingExplodeSprite extends Sprite2D

signal ended(o :HommingExplodeSprite)

const LIFE_SEC = 1.0
const SCALE = 1.0

var team :Team.Type = Team.Type.NONE
var life_start :float

func spawn(t :Team.Type, p :Vector2):
	team = t
	self_modulate = Team.TeamColor[t]
	position = p
	life_start = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		emit_signal("ended",self)
		return
	var rate = dur / LIFE_SEC
	self_modulate.a = cos(rate*PI/2)
	scale = Vector2( (1 + sin(rate*PI))/2 *SCALE , (1 + cos(rate*PI))/2 * SCALE )
	rotate(delta*PI*4)
