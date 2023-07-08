class_name BulletExplodeSprite extends Sprite2D

signal ended(o :BulletExplodeSprite)

var team :int
var life_start :float
const SCALE = 0.5

func spawn(t :Team.Type, p :Vector2):
	team = t
	self_modulate = Team.TeamColor[t]
	position = p
	life_start = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	self_modulate.a = cos(dur*PI/2)
	scale = Vector2( (1 + sin(dur*PI))/2 *SCALE , (1 + cos(dur*PI))/2 * SCALE )
	rotate(delta*PI)

func _on_timer_timeout() -> void:
	emit_signal("ended",self)
#	queue_free()

