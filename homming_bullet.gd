class_name HommingBullet extends Area2D

signal ended(p :Vector2)
signal inc_team_stat(team : Team.Type, statname: String)

const SPEED_LIMIT :float = 300

var speed :float
var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var alive := true
var dest_ball :Ball
var velocity :Vector2
var accel :Vector2

func spawn(t :Team.Type, p :Vector2, bl :Ball)->void:
	team = t
	$Sprite2D.self_modulate = Team.TeamColor[t]
	dest_ball = bl
	dest_ball.ended.connect(dest_ball_end)
	position = p
	rotate_dir = randf_range(-5,5)
	speed = randfn(SPEED_LIMIT, SPEED_LIMIT/10.0)
	if speed < 100 :
		speed = 100
	$TimerLife.wait_time = 10
	$TimerLife.start()

func dest_ball_end(_t :Team.Type, _p :Vector2):
	end()

func end():
	if alive:
		alive = false
		emit_signal("ended", position)
		queue_free()

func _physics_process(delta: float) -> void:
	velocity = velocity.limit_length(speed)
	position += velocity * delta
	velocity +=accel
	if randf() < 0.1:
		accel = (dest_ball.position - position)

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
