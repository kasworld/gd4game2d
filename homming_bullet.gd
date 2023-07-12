class_name HommingBullet extends Area2D

signal ended(o :HommingBullet)

const SPEED_LIMIT :float = 300
const LIFE_SEC = 10.0

var inc_team_stat :Callable # func(team : ColorTeam, statname: String)

var speed :float
var team :ColorTeam
var dest_ball :Ball
var velocity :Vector2
var accel :Vector2
var alive :bool
var life_start :float

func _ready()->void:
	inc_team_stat = get_tree().current_scene.inc_team_stat

func spawn(t :ColorTeam, p :Vector2, bl :Ball)->void:
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	$Sprite2D.self_modulate = t.color
	dest_ball = bl
	connect_if_not(dest_ball.ended,dest_ball_end)
	position = p
	speed = randfn(SPEED_LIMIT, SPEED_LIMIT/10.0)
	if speed < SPEED_LIMIT/3 :
		speed = SPEED_LIMIT/3

func connect_if_not(sg :Signal, fn :Callable):
	if not sg.is_connected(fn):
		sg.connect(fn)

func change_color():
	if $Sprite2D.self_modulate == team.color:
		$Sprite2D.self_modulate = dest_ball.team.color
	else:
		$Sprite2D.self_modulate = team.color

func dest_ball_end(_o :Ball):
	end()

func end():
	if alive:
		alive = false
		emit_signal("ended",self)

var frame := 0
func _process(_delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		end()
		return

	frame+=1
	if frame % 15 == 0:
		change_color()

func _physics_process(delta: float) -> void:
	velocity = velocity.limit_length(speed)
	position += velocity * delta
	velocity +=accel
	if randf() < 0.1:
		accel = (dest_ball.position - position)

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
