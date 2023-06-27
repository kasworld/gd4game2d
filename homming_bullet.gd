class_name HommingBullet extends Area2D

signal ended(p :Vector2)

var speed :float = 150.0
var rotate_dir :float
var team :int = -1
var alive := true
var dest_ball :Ball
var velocity :Vector2

func spawn(c :int,p :Vector2, bl :Ball)->void:
	c = c % 16
	team = c / 2
	$AnimatedSprite2D.frame = c / 2
	dest_ball = bl
	dest_ball.ended.connect(dest_ball_end)
	position = p
	rotate_dir = randf_range(-5,5)
	$TimerLife.wait_time = 10
	$TimerLife.start()
	velocity = (dest_ball.position - position).normalized() * speed

func dest_ball_end(c :int, p :Vector2):
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


