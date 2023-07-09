class_name HommingBullet extends Area2D

signal ended(o :HommingBullet)
signal inc_team_stat(team : Team.Type, statname: String)

const SPEED_LIMIT :float = 300
const LIFE_SEC = 10.0

var speed :float
var team :Team.Type = Team.Type.NONE
var alive :bool
var dest_ball :Ball
var velocity :Vector2
var accel :Vector2

func spawn(t :Team.Type, p :Vector2, bl :Ball)->void:
	team = t
	alive = true
	$Sprite2D.self_modulate = Team.TeamColor[t]
	dest_ball = bl
	connect_if_not(dest_ball.ended,dest_ball_end)
	position = p
	speed = randfn(SPEED_LIMIT, SPEED_LIMIT/10.0)
	if speed < SPEED_LIMIT/3 :
		speed = SPEED_LIMIT/3
	$TimerLife.wait_time = LIFE_SEC
	$TimerLife.start()

func connect_if_not(sg :Signal, fn :Callable):
	if not sg.is_connected(fn):
		sg.connect(fn)

func change_color():
	if $Sprite2D.self_modulate == Team.TeamColor[team]:
		$Sprite2D.self_modulate = Team.TeamColor[dest_ball.team]
	else:
		$Sprite2D.self_modulate = Team.TeamColor[team]

var frame := 0
func _process(_delta: float) -> void:
	frame+=1
	if frame % 15 == 0:
		change_color()

func dest_ball_end(_o :Ball):
	end()

func end():
	if alive:
		alive = false
		emit_signal("ended",self)

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
