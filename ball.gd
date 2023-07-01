class_name Ball extends Area2D

var shield_scene = preload("res://shield.tscn")

signal fire_bullet(t :Team.Type, p :Vector2, v :Vector2)
signal fire_homming(t :Team.Type, p :Vector2, dest :Ball)
signal shield_ended(p :Vector2)
signal ended(t :Team.Type, p :Vector2)

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

func clamp_pos()->void:
	var vp = get_viewport_rect()
	if not vp.has_point( position):
		var oldp = position
		var r = get_radius()
		var clampvt = Vector2(r*4,r*4)
		position = position.clamp(vp.position + clampvt, vp.end - clampvt)
		print("invalid ball(%s) pos %s to %s" % [get_age_sec(),oldp, position])

func spawn(t :Team.Type, p :Vector2):
	$ColorBallSprites.frame = t*2 + randi_range(0,1)
	team = t
	position = p
	clamp_pos()
	velocity = random_vector2()*speed_limit
	rotate_dir = randf_range(-5,5)

func add_shield():
	get_tree().current_scene.inc_team_stat(team,"new_shield")
	var sh = shield_scene.instantiate()
	add_child(sh)
	sh.ended.connect(shield_end)
	sh.spawn(team)

func shield_end(p :Vector2):
	emit_signal("shield_ended",p)

func _process(delta: float) -> void:
	rotate(delta*rotate_dir)
	if randf() < 5.0*delta :
		emit_signal("fire_bullet",team, position, random_vector2())
	if randf() < 2.0*delta :
		emit_signal("fire_homming",team, position, null)
	if randf() < 2.0*delta :
		add_shield()

func _physics_process(delta: float) -> void:
#	$AI.accel(team,delta,velocity)
	if randf() < 5.0*delta:
		get_tree().current_scene.inc_team_stat(team,"accel")
		velocity = velocity.rotated( (randf()-0.5)*PI)
	velocity = velocity.limit_length(speed_limit)
	position += velocity * delta
	clamp_pos()

func end():
	if alive:
		alive = false
		emit_signal("ended", team, position)
		queue_free()

func random_vector2() ->Vector2:
	return Vector2.DOWN.rotated( randf() * 2 * PI )

func line2normal(l ) -> Vector2:
	return (l.b - l.a).orthogonal().normalized()

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	if area is Wall:
		var other_shape_owner = area.shape_find_owner(area_shape_index)
		var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
		var nvt = line2normal(other_shape_node.shape)
		velocity = velocity.bounce(nvt)
	elif area is Ball:
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

