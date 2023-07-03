class_name Ball extends Area2D

var shield_scene = preload("res://shield.tscn")

signal fire_bullet(t :Team.Type, p :Vector2, v :Vector2)
signal fire_homming(t :Team.Type, p :Vector2, dest :Ball)
signal shield_ended(p :Vector2)
signal ended(t :Team.Type, p :Vector2)
signal inc_team_stat(team : Team.Type, statname: String)

var team :Team.Type = Team.Type.NONE
const speed_limit :float = 200
var rotate_dir :float
var velocity :Vector2
var alive := true
var life_start := Time.get_unix_time_from_system()
var ai :AI

func _ready() -> void:
	ai = AI.new()
	add_child(ai)

func get_age_sec()->float:
	return Time.get_unix_time_from_system() - life_start

func get_radius()->float:
	return $CollisionShape2D.shape.radius

func spawn(t :Team.Type, p :Vector2):
	$ColorBallSprites.frame = t*2 + randi_range(0,1)
	team = t
	position = p
	velocity = random_vector2()*speed_limit
	rotate_dir = randf_range(-5,5)
	monitorable = true
	monitoring = true
	visible = true

func add_shield():
	emit_signal("inc_team_stat",team,"new_shield")
	var sh = shield_scene.instantiate()
	add_child(sh)
	sh.ended.connect(shield_end)
	sh.inc_team_stat.connect(
		func(t : Team.Type, statname: String):
			emit_signal("inc_team_stat",t,statname)
			)
	sh.spawn(team)

func shield_end(p :Vector2):
	emit_signal("shield_ended",p)

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)
	var v = ai.do_fire_bullet(team,delta,most_danger_area2d)
	if v != Vector2.ZERO:
		emit_signal("fire_bullet",team, position, v)

	var dst = ai.do_fire_homming(team,delta,most_danger_area2d)
	if dst != null:
		emit_signal("fire_homming",team, position, dst)

	if ai.do_add_shield(team,delta,position,velocity):
		add_shield()

func _physics_process(delta: float) -> void:
	var oldv = velocity
	velocity = ai.do_accel(team,delta,position,velocity, most_danger_area2d)
	if oldv != velocity:
		emit_signal("inc_team_stat",team,"accel")

	position += velocity * delta

	var r = get_radius()
	var vp = get_viewport_rect().size

	if position.x < r :
		position.x = r
		velocity.x = abs(velocity.x)
	elif position.x > vp.x - r:
		position.x = vp.x - r
		velocity.x = -abs(velocity.x)
	if position.y < r :
		position.y = r
		velocity.y = abs(velocity.y)
	elif position.y > vp.y - r:
		position.y = vp.y - r
		velocity.y = -abs(velocity.y)

	most_danger_value = 0
	most_danger_area2d = null

func end():
	if alive:
		alive = false
		emit_signal("ended", team, position)
		queue_free()

func random_vector2() ->Vector2:
	return Vector2.DOWN.rotated( randf() * 2 * PI )

func line2normal(l ) -> Vector2:
	return (l.b - l.a).orthogonal().normalized()

var most_danger_area2d :Area2D # ball , bullet, shield, homming
var most_danger_value :float = 0

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var local_shape_owner = shape_find_owner(local_shape_index)
	var local_shape_node = shape_owner_get_owner(local_shape_owner)
	if local_shape_node == $CollisionShape2D:
		if area is Ball:
			if area.team != team and area_shape_index == 0:
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
			print_debug("unknown Area2 ", area)

	elif local_shape_node == $Scan1:
		if not(area is Wall):
			var dval = ai.calc_danger_level(self, area)
			if dval > most_danger_value:
				most_danger_value = dval
				most_danger_area2d = area
	else:
		print_debug("unknown local shape ", local_shape_node)
