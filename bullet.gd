class_name Bullet extends Area2D

const SPEED_LIMIT :float = 500.0
const LIFE_SEC = 10.0

var team :ColorTeam
var velocity :Vector2
var alive :bool
var life_start :float

func spawn(t :ColorTeam,p :Vector2, v :Vector2):
	t.inc_stat(ColorTeam.Stat.NEW_BULLET)
	$Sprite2D.self_modulate = t.color
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	position = p
	velocity = v.normalized() * SPEED_LIMIT

func end():
	if alive:
		alive = false
		get_tree().current_scene.bullet_end(self)

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

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
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
