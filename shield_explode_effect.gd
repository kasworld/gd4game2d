class_name ShieldExplodeSprite extends Sprite2D

const LIFE_SEC := 1.0
const SCALE := 0.5

var team :ColorTeam
var life_start :float

func spawn(t :ColorTeam, p :Vector2):
	team = t
	self_modulate = t.color
	position = p
	life_start = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var dur := Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		get_tree().current_scene.shield_explode_effect_end(self)
		return
	var rate := dur / LIFE_SEC
	self_modulate.a = cos(rate*PI/2)
	scale = Vector2( (1 + sin(rate*PI))/2 *SCALE , (1 + cos(rate*PI))/2 * SCALE )
	rotate(delta*PI*4)
