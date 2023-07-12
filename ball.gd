class_name Ball extends Area2D

signal fire_bullet(t :ColorTeam, p :Vector2, v :Vector2)
signal fire_homming(t :ColorTeam, p :Vector2, dest :Ball)
signal shield_add(b:Ball)
signal shield_ended_from_ball(o :Shield)
signal ended(o :Ball)

const SPEED_LIMIT :float = 200
const MAX_SHIELD = 12
const INIT_SHIELD = 12

var shield_free_list = Node2DPool.new(preload("res://shield.tscn").instantiate)
var inc_team_stat :Callable # func(team : ColorTeam, statname: String)
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

func spawn(t :ColorTeam, p :Vector2, inc_team_stat_arg :Callable):
	inc_team_stat = inc_team_stat_arg
	$ColorBallSprite.self_modulate = t.color
	team = t
	alive = true
	life_start = Time.get_unix_time_from_system()
	position = p
	velocity = Vector2.DOWN.rotated( randf() * 2 * PI )*SPEED_LIMIT
	monitorable = true
	monitoring = true
	visible = true
	for i in INIT_SHIELD:
		add_shield()

func get_shield_count()->int:
	return $ShieldContainer.get_child_count()

func add_shield():
	if get_shield_count() >= MAX_SHIELD:
		return
	inc_team_stat.call(team,"new_shield")
	var sh = shield_free_list.get_node2d()
	$ShieldContainer.add_child(sh)
	sh.spawn(team, inc_team_stat, shield_end)

func connect_if_not(sg :Signal, fn :Callable):
	if not sg.is_connected(fn):
		sg.connect(fn)

func shield_end(sh :Shield):
	emit_signal("shield_ended_from_ball",sh)
	shield_free_list.put_node2d(sh)
	$ShieldContainer.remove_child.call_deferred(sh)

func end():
	if alive:
		alive = false
		emit_signal("ended", self)

func _process(delta: float) -> void:
	var v = AI.do_fire_bullet(position, team,delta,most_danger_area2d,find_other_team_ball)
	if v != Vector2.ZERO:
		emit_signal("fire_bullet",team, position, v)

	var dst = AI.do_fire_homming(team,delta,most_danger_area2d,find_other_team_ball)
	if dst != null:
		emit_signal("fire_homming",team, position, dst)

	if AI.do_add_shield(delta):
		add_shield()

func _physics_process(delta: float) -> void:
	var oldv = velocity
	velocity = AI.do_accel(delta,position,velocity, most_danger_area2d)
	if oldv != velocity:
		inc_team_stat.call(team,"accel")

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
				inc_team_stat.call(area.team,"kill_ball")
				end()
		elif area is Bullet:
			if area.team != team:
				inc_team_stat.call(area.team,"kill_bullet")
				end()
		elif area is Shield:
			if area.team != team:
				inc_team_stat.call(area.team,"kill_shield")
				end()
		elif area is HommingBullet:
			if area.team != team:
				inc_team_stat.call(area.team,"kill_homming")
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
