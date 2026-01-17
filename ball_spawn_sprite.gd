class_name BallSpawnSprite extends Sprite2D

const LIFE_SEC := 1.0
const SCALE := 1.0

var team :ColorTeam
var life_start :float

func spawn(t :ColorTeam, p :Vector2):
	self_modulate = t.color
	team = t
	position = p
	self_modulate.a = 0
	life_start = Time.get_unix_time_from_system()

func _process(_delta: float) -> void:
	var dur := Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		get_tree().current_scene.ball_spawn_effect_end(self)
		return
	var rate := dur / LIFE_SEC
	self_modulate.a = sin(rate*PI/2)
	scale = Vector2( (1 + sin(rate*PI))/2 *SCALE , (1 + sin(rate*PI))/2 * SCALE )
