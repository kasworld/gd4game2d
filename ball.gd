class_name Ball extends Area2D

signal shield_add(b:Ball)
signal ended(o :Ball)

const SPEED_LIMIT :float = 200
const MAX_SHIELD = 12
const INIT_SHIELD = 12

var shield_free_list = Node2DPool.new(preload("res://shield.tscn").instantiate)
var find_other_team_ball :Callable
var team :ColorTeam
var velocity :Vector2
var vp_size :Vector2
var bounce_radius :float
var alive :bool
var life_start :float

func _ready() -> void:
	find_other_team_ball = get_tree().current_scene.find_other_team_ball
	vp_size = get_viewport_rect().size
	bounce_radius = $CollisionShape2D.shape.radius

func spawn(t :ColorTeam, p :Vector2):
	$ColorBallSprite.self_modulate = t.color
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	position = p
	velocity = Vector2.DOWN.rotated( randf() * 2 * PI )*SPEED_LIMIT
	monitorable = true
	monitoring = true
	visible = true
	for o in $ShieldContainer.get_children():
		o.spawn(team, shield_end)
	for i in INIT_SHIELD:
		add_shield()


func get_shield_count()->int:
	return $ShieldContainer.get_child_count()

func add_shield():
	if get_shield_count() >= MAX_SHIELD:
		return
	team.inc_stat(ColorTeam.Stat.NEW_SHIELD)
	var sh = shield_free_list.get_node2d()
	$ShieldContainer.add_child(sh)
	sh.spawn(team, shield_end)

func shield_end(sh :Shield):
	shield_free_list.put_node2d(sh)
	$ShieldContainer.remove_child.call_deferred(sh)
	get_tree().current_scene.shield_explode_effect(sh)

func end():
	if alive:
		alive = false
		emit_signal("ended", self)

func _process(delta: float) -> void:
	var v = AI.do_fire_bullet(position, team,delta,most_danger_area2d,find_other_team_ball)
	if v != Vector2.ZERO:
		get_tree().current_scene.fire_bullet(team, position, v)

	var dst = AI.do_fire_homming(team,delta,most_danger_area2d,find_other_team_ball)
	if dst != null:
		get_tree().current_scene.fire_homming(team, position, dst)

	if AI.do_add_shield(delta):
		add_shield()

func _physics_process(delta: float) -> void:
	var oldv = velocity
	velocity = AI.do_accel(delta,position,velocity, most_danger_area2d)
	if oldv != velocity:
		team.inc_stat(ColorTeam.Stat.ACCEL)

	position += velocity * delta
	var bn = Bounce.new(position,velocity,vp_size,bounce_radius)
	position = bn.position
	velocity = bn.velocity

	most_danger_value = 0
	most_danger_area2d = null

var most_danger_area2d :Area2D # ball , bullet, shield, homming
var most_danger_value :float = 0

func _on_area_shape_entered(_area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var local_shape_owner = shape_find_owner(local_shape_index)
	var local_shape_node = shape_owner_get_owner(local_shape_owner)
	if local_shape_node == $CollisionShape2D:
		if area is Ball:
			if area.team != team and area_shape_index == 0:
				area.team.inc_stat(ColorTeam.Stat.KILL_BALL)
				end()
		elif area is Bullet:
			if area.team != team:
				area.team.inc_stat(ColorTeam.Stat.KILL_BULLET)
				end()
		elif area is Shield:
			if area.team != team:
				area.team.inc_stat(ColorTeam.Stat.KILL_SHIELD)
				end()
		elif area is HommingBullet:
			if area.team != team:
				area.team.inc_stat(ColorTeam.Stat.KILL_HOMMING)
				end()
		else:
			print_debug("unknown Area2 ", area)

	elif local_shape_node == $Scan1:
		var dval = AI.calc_danger_level(self, area)
		if dval > most_danger_value:
			most_danger_value = dval
			most_danger_area2d = area
	else:
		print_debug("unknown local shape ", local_shape_node)
