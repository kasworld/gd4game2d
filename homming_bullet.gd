class_name HommingBullet extends Area2D

signal ended(p :Vector2)

var speed_limit :float = 300
var speed :float
var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var alive := true
var dest_ball :Ball
var velocity :Vector2
var accel :Vector2

func spawn(t :Team.Type, p :Vector2, bl :Ball)->void:
	team = t
	$AnimatedSprite2D.frame = t
	dest_ball = bl
	dest_ball.ended.connect(dest_ball_end)
	position = p
	rotate_dir = randf_range(-5,5)
	speed = randfn(speed_limit, speed_limit/10.0)
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

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)

func _physics_process(delta: float) -> void:
	velocity = velocity.limit_length(speed)
	position += velocity * delta
	velocity +=accel
	accel = (dest_ball.position - position)

func _on_timer_life_timeout() -> void:
	end()

func _on_area_entered(area: Area2D) -> void:
	if area is Ball:
		if area.team != team:
			get_tree().current_scene.inc_team_stat(area.team,"kill_ball")
			end()
	elif area is Bullet:
		if area.team != team:
			get_tree().current_scene.inc_team_stat(area.team,"kill_bullet")
			end()
	elif area is Shield:
		if area.team != team:
			get_tree().current_scene.inc_team_stat(area.team,"kill_shield")
			end()
	elif area is HommingBullet:
		if area.team != team:
			get_tree().current_scene.inc_team_stat(area.team,"kill_homming")
			end()


