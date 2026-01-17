class_name Shield extends Area2D

var shield_end_in_ball :Callable
var rotate_dir :float
var team :ColorTeam
var alive :bool
var life_start :float
var life_limit_sec :float

func spawn(t :ColorTeam, shieldendfn :Callable):
	shield_end_in_ball = shieldendfn
	$Sprite2D.self_modulate = t.color
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	rotate_dir = randfn(0,PI*2)
	life_limit_sec = randfn(Global.ShieldLiftSec,Global.ShieldLiftSec/10)

func end():
	if alive:
		alive = false
		shield_end_in_ball.call(self)

func _process(delta: float) -> void:
	var dur := Time.get_unix_time_from_system() - life_start
	if dur > life_limit_sec:
		end()
		return
	position = position.rotated(delta*rotate_dir)

func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	area.team.inc_stat(ColorTeam.Stat.KILL_SHIELD)
	end()
