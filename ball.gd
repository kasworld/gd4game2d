class_name Ball extends Area2D

var shield_scene = preload("res://shield.tscn")

signal fire_bullet(t :Team.Type, p :Vector2, v :Vector2)
signal fire_homming(t :Team.Type, p :Vector2, dest :Ball)
signal shield_ended(p :Vector2)
signal ended(t :Team.Type, p :Vector2)
signal inc_team_stat(team : Team.Type, statname: String)

var team :Team.Type = Team.Type.NONE
var speed_limit :float = 200
var rotate_dir :float
var velocity :Vector2
var alive := true
var life_start := Time.get_unix_time_from_system()

func get_age_sec()->float:
	return Time.get_unix_time_from_system() - life_start

func get_radius()->float:
	return $CollisionShape2D.shape.radius

func make_spawn_pos()->Vector2:
	var vp = get_viewport_rect().size
	var clampr = get_radius()*3
	var p = Vector2(
		randf_range(clampr,vp.x-clampr),
		randf_range(clampr,vp.y-clampr),
		)
	return p

func clamp_pos()->void:
	var vp = get_viewport_rect()
	if not vp.has_point( position):
		var oldp = position
		var r = get_radius()
		var clampvt = Vector2(r*3,r*3)
		position = position.clamp(vp.position + clampvt, vp.end - clampvt)
		print("invalid ball(%s) pos %s to %s" % [get_age_sec(),oldp, position])

func spawn(t :Team.Type, p :Vector2):
	$ColorBallSprites.frame = t*2 + randi_range(0,1)
	team = t
	position = p
	clamp_pos()
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
	if AI.do_fire_bullet(team,delta,position,velocity):
		emit_signal("fire_bullet",team, position, Vector2.ZERO)
	if AI.do_fire_homming(team,delta,position,velocity):
		emit_signal("fire_homming",team, position, null)
	if AI.do_add_shield(team,delta,position,velocity):
		add_shield()

func _physics_process(delta: float) -> void:
	if AI.do_accel(team,delta,position,velocity):
		emit_signal("inc_team_stat",team,"accel")
		velocity = velocity.rotated( (randf()-0.5)*PI)

	velocity = velocity.limit_length(speed_limit)
	position += velocity * delta
	clamp_pos()
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
#	var local_shape_owner = shape_find_owner(local_shape_index)
#	var local_shape_node = shape_owner_get_owner(local_shape_owner)
#	print_debug("ball ",local_shape_index," ",local_shape_owner," ",local_shape_node)
	match local_shape_index:
		0: # $CollisionShape2D
			if area is Wall:
				var other_shape_owner = area.shape_find_owner(area_shape_index)
				var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
				var nvt = line2normal(other_shape_node.shape)
				velocity = velocity.bounce(nvt)
			elif area is Ball:
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
		1: # $Scan1
			if area is Wall:
				pass
			else :
				var dval = AI.calc_danger_level(self, area)
				if dval > most_danger_value:
					most_danger_value = dval
					most_danger_area2d = area
#					print_debug(most_danger_area2d,most_danger_value)
