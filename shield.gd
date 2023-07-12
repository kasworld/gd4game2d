class_name Shield extends Area2D

const LIFE_SEC = 10.0

var inc_team_stat :Callable # func(team : ColorTeam, statname: String)
var shield_end_in_ball :Callable

var rotate_dir :float
var team :ColorTeam
var alive :bool
var life_start :float
var life_limit_sec :float

func _ready()->void:
	inc_team_stat = get_tree().current_scene.inc_team_stat

func spawn(t :ColorTeam, shieldendfn :Callable):
	shield_end_in_ball = shieldendfn
	$Sprite2D.self_modulate = t.color
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	rotate_dir = randf_range(-5,5)
	life_limit_sec = randfn(LIFE_SEC,LIFE_SEC/10)

func end():
	if alive:
		alive = false
		shield_end_in_ball.call(self)

func _process(delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	if dur > life_limit_sec:
		end()
		return
	position = position.rotated(delta*rotate_dir)

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	if area is Ball:
		if area_shape_index != 0: # ball kill area
			return
		if area.team != team:
			inc_team_stat.call(area.team,"kill_ball")
			end()
	elif area is Bullet:
		if area.team != team:
			inc_team_stat.call(area.team,"kill_bullet")
			end()
	elif area is Shield:
		if area.team != team:
			inc_team_stat.call(area.team,"kill_shield")
			end()
	elif area is HommingBullet:
		if area.team != team:
			inc_team_stat.call(area.team,"kill_homming")
			end()
	else:
		print_debug("unknown Area2D ", area)
