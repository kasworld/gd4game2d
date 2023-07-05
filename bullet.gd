class_name Bullet extends Area2D

signal ended(p :Vector2)
signal inc_team_stat(team : Team.Type, statname: String)

const SPEED_LIMIT :float = 300.0

var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var velocity :Vector2
var alive := true

func spawn(t :Team.Type,p :Vector2, v :Vector2)->void:
	$Sprite2D.self_modulate = Team.TeamColor[t]
	team = t
	position = p
	velocity = v.normalized() * SPEED_LIMIT
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = 10
	$TimerLife.start()

func end():
	if alive:
		alive = false
		emit_signal("ended", position)
		queue_free()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(SPEED_LIMIT)

func _on_timer_life_timeout() -> void:
	end()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
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
