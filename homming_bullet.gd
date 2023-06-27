class_name HommingBullet extends Area2D

signal ended(p :Vector2)

var speed :float = 150.0
var rotate_dir :float
var team :Team.Type = Team.Type.NONE
var alive := true
var dest_ball :Ball
var velocity :Vector2

func spawn(t :Team.Type, p :Vector2, bl :Ball)->void:
	team = t
	$AnimatedSprite2D.frame = t
	dest_ball = bl
	dest_ball.ended.connect(dest_ball_end)
	position = p
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = 10
	$TimerLife.start()
	velocity = (dest_ball.position - position).normalized() * speed

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
	if dest_ball == null or not dest_ball.alive :
		end()
		return
	position += velocity * delta
	velocity = (dest_ball.position - position).normalized() * speed

func _on_timer_life_timeout() -> void:
	end()

func _on_area_entered(area: Area2D) -> void:
	if area is Ball:
		if area.team != team:
			end()
	elif area is Bullet:
		if area.team != team:
			end()
	elif area is Shield:
		if area.team != team:
			end()
	elif area is HommingBullet:
		if area.team != team:
			end()


