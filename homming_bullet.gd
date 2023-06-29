class_name HommingBullet extends Area2D

signal ended(p :Vector2)

var speed_limit :float = 300
var speed :float
var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var alive := true
var dest_ball :Ball
var velocity :Vector2
var dest_pos :Array[Vector2]
var dest_pos_len = 10

func spawn(t :Team.Type, p :Vector2, bl :Ball)->void:
	team = t
	$AnimatedSprite2D.frame = t
	dest_ball = bl
	dest_ball.ended.connect(dest_ball_end)
	position = p
	rotate_dir = randf_range(-5,5)
	speed = randf_range(speed_limit/2, speed_limit)
	$TimerLife.wait_time = 10
	$TimerLife.start()
	for i in range(dest_pos_len):
		dest_pos.push_back(dest_ball.position)
	update_velocity()

func dest_ball_end(_t :Team.Type, _p :Vector2):
	end()

func update_velocity():
	if dest_ball != null:
		var dp = dest_pos.pop_front()
		velocity += (dp - position).normalized() * speed
		velocity = velocity.limit_length(speed)
		dest_pos.push_back(dest_ball.position)

func end():
	if alive:
		alive = false
		emit_signal("ended", position)
		queue_free()

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	update_velocity()

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


