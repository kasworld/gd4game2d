class_name HommingBullet extends Area2D

const SPEED_LIMIT :float = 300
const LIFE_SEC = 10.0

var speed :float
var team :ColorTeam
var dest_ball :Ball
var velocity :Vector2
var accel :Vector2
var alive :bool
var life_start :float

func spawn(t :ColorTeam, p :Vector2, bl :Ball)->void:
	t.inc_stat(ColorTeam.Stat.NEW_HOMMING)
	team = t
	dest_ball = bl
	alive = true
	life_start = Time.get_unix_time_from_system()
	$InnerSprite.self_modulate = team.color
	$OuterSprite.self_modulate = dest_ball.team.color

	AI.connect_if_not(dest_ball.ended,dest_ball_end)
	position = p
	speed = randfn(SPEED_LIMIT, SPEED_LIMIT/10.0)
	if speed < SPEED_LIMIT/3 :
		speed = SPEED_LIMIT/3

func dest_ball_end(_o :Ball):
	end()

func end():
	if alive:
		alive = false
		get_tree().current_scene.homming_end(self)

func _process(_delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		end()
		return

func _physics_process(delta: float) -> void:
	if dest_ball == null or not dest_ball.alive:
		end()
		return
	velocity = velocity.limit_length(speed)
	position += velocity * delta
	velocity +=accel
	if randf() < 0.1:
		accel = (dest_ball.position - position)

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	if area_shape_index != 0: # ball kill area
		return
	if area.team == team:
		return
	if area is Ball:
		area.team.inc_stat(ColorTeam.Stat.KILL_BALL)
		end()
	elif area is Bullet:
		area.team.inc_stat(ColorTeam.Stat.KILL_BULLET)
		end()
	elif area is Shield:
		area.team.inc_stat(ColorTeam.Stat.KILL_SHIELD)
		end()
	elif area is HommingBullet:
		area.team.inc_stat(ColorTeam.Stat.KILL_HOMMING)
		end()
	else:
		print_debug("unknown Area2D ", area, typeof(area))
