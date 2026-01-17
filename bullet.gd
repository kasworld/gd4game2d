class_name Bullet extends Area2D

var team :ColorTeam
var velocity :Vector2
var alive :bool
var life_start :float

func spawn(t :ColorTeam,p :Vector2, v :Vector2):
	t.inc_stat(ColorTeam.Stat.NEW_BULLET)
	$MainSprite.self_modulate = t.color
	$SubSprite.self_modulate = t.color.inverted()
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	position = p
	velocity = v.normalized() * Global.BulletSpeed

func end():
	if alive:
		alive = false
		get_tree().current_scene.bullet_end(self)

func _process(_delta: float) -> void:
	var dur := Time.get_unix_time_from_system() - life_start
	if dur > Global.BulletLiftSec:
		end()
		return

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(Global.BulletSpeed)
	rotation = velocity.angle()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	end()

func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	area.team.inc_stat(ColorTeam.Stat.KILL_BULLET)
	end()
