class_name HommingBullet extends Area2D

const LIFE_SEC = 10.0
const SPEED_LIMIT :float = 600
var speed :float
var team :ColorTeam
var target :Area2D
var velocity :Vector2
var accel :Vector2
var alive :bool
var life_start :float

func spawn(t :ColorTeam, p :Vector2, tg :Area2D)->void:
	t.inc_stat(ColorTeam.Stat.NEW_HOMMING)
	team = t
	target = tg
	alive = true
	life_start = Time.get_unix_time_from_system()
	$InnerSprite.self_modulate = target.team.color
	$OuterSprite.self_modulate = team.color

	position = p
	speed = randfn(SPEED_LIMIT, SPEED_LIMIT/10.0)
	if speed < SPEED_LIMIT/3 :
		speed = SPEED_LIMIT/3

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
	if target == null or not target.alive:
		end()
		return
	velocity = velocity.limit_length(speed)
	position += velocity * delta
	velocity +=accel
	rotation = velocity.angle()
	if randf() < 0.1:
		accel = (target.position - position)

func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	area.team.inc_stat(ColorTeam.Stat.KILL_HOMMING)
	end()
