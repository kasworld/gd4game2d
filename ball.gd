class_name Ball extends Area2D

var shield_scene = preload("res://shield.tscn")
var get_ball_list :Callable
var team :ColorTeam
var velocity :Vector2
var vp_area :Rect2
var bounce_radius :float
var alive :bool
var life_start :float

func _ready() -> void:
	get_ball_list = get_tree().current_scene.get_ball_list
	vp_area = get_viewport_rect()
	bounce_radius = $CollisionShape2D.shape.radius

func spawn(t :ColorTeam, p :Vector2, show_dp :bool):
	t.inc_stat(ColorTeam.Stat.NEW_BALL)
	$ColorBallSprite.self_modulate = t.color
	$DirSprite.self_modulate = t.color.inverted()
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	position = p
	velocity = Vector2.DOWN.rotated( randf() * 2 * PI )*Global.BallSpeed
	show_danger_pointer(show_dp)
	for o in $ShieldContainer.get_children():
		o.spawn(team, shield_end)
	for i in Global.ShieldCount:
		add_shield()

func get_shield_count()->int:
	return $ShieldContainer.get_child_count()

func add_shield():
	if get_shield_count() >= Global.ShieldCount:
		return
	team.inc_stat(ColorTeam.Stat.NEW_SHIELD)
	var sh = shield_scene.instantiate()
	$ShieldContainer.add_child(sh)
	sh.spawn(team, shield_end)

func shield_end(sh :Shield):
	$ShieldContainer.remove_child.call_deferred(sh)
	sh.queue_free()
	get_tree().current_scene.shield_explode_effect(sh)

func end():
	if alive:
		alive = false
		get_tree().current_scene.ball_end(self)

func _process(delta: float) -> void:
	var r_scene = get_tree().current_scene
	var node_list = r_scene.qt.search(position, 300,300)
	var danger_dict = AI.find_danger_objs(self,node_list)
#	var danger_dict = {
#		"All":[null, 0.0],
#		"Ball":[null, 0.0],
#		"Bullet":[null, 0.0],
#		"Homming":[null, 0.0],
#	}
	$DangerPointerContainer.update_danger_dict(self, danger_dict)

	var oldv = velocity
	velocity = AI.accel_to_evade(vp_area.size, position, velocity, danger_dict.All[0])
	if oldv != velocity:
		team.inc_stat(ColorTeam.Stat.ACCEL)

	var v = AI.do_fire_bullet(position, team,delta,danger_dict,get_ball_list.call())
	if v != Vector2.ZERO:
		r_scene.fire_bullet(team, position, v)

	var dst = AI.do_fire_homming(team,delta,danger_dict,get_ball_list.call())
	if dst != null :
		r_scene.fire_homming(team, position, dst)

	if AI.do_add_shield(delta):
		add_shield()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	var bn = Bounce.bounce2d(position,velocity,vp_area,bounce_radius)
	position = bn.position
	velocity = bn.velocity
	$DirSprite.position = Vector2.RIGHT.rotated(velocity.angle())*20

func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	area.team.inc_stat(ColorTeam.Stat.KILL_BALL)
	end()

func show_danger_pointer(b :bool):
	$DangerPointerContainer.visible = b
