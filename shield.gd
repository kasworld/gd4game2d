class_name Shield extends Area2D

signal ended(team : Team.Type, p :Vector2)
signal inc_team_stat(team : Team.Type, statname: String)

const LIFE_SEC = 10

var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var alive := true

func spawn(t :Team.Type):
	$Sprite2D.self_modulate = Team.TeamColor[t]
	team = t
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = randfn(LIFE_SEC,LIFE_SEC/10)
	$TimerLife.start()

func end():
	if alive:
		alive = false
		emit_signal("ended",team, global_position)
		queue_free()

func _process(delta: float) -> void:
	position = position.rotated(delta*rotate_dir)

func _on_timer_life_timeout() -> void:
	end()

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	if area is Ball:
		if area_shape_index != 0: # ball kill area
			return
		if area.team != team:
			emit_signal("inc_team_stat",area.team,"kill_ball")
			end()
	elif area is Bullet:
		if area.team != team:
			emit_signal("inc_team_stat",area.team,"kill_bullet")
			end()
	elif area is Shield:
		if area.team != team:
			emit_signal("inc_team_stat",area.team,"kill_shield")
			end()
	elif area is HommingBullet:
		if area.team != team:
			emit_signal("inc_team_stat",area.team,"kill_homming")
			end()
	else:
		print_debug("unknown Area2D ", area)
