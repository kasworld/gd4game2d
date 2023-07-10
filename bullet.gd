class_name Bullet extends Area2D

signal ended(o :Bullet)
signal inc_team_stat(team : ColorTeam, statname: String)

const SPEED_LIMIT :float = 500.0
const LIFE_SEC = 10.0

var team :ColorTeam
var velocity :Vector2
var alive :bool
var life_start :float

func spawn(t :ColorTeam,p :Vector2, v :Vector2)->void:
	$Sprite2D.self_modulate = t.color
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	position = p
	velocity = v.normalized() * SPEED_LIMIT

func end():
	if alive:
		alive = false
		emit_signal("ended",self)

func _process(_delta: float) -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	if dur > LIFE_SEC:
		end()
		return

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(SPEED_LIMIT)

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
