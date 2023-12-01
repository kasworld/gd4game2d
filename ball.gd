class_name Ball extends Area2D

const SPEED_LIMIT :float = 200
const MAX_SHIELD = 12
const INIT_SHIELD = 12

var shield_free_list = Node2DPool.new(preload("res://shield.tscn").instantiate)
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
	velocity = Vector2.DOWN.rotated( randf() * 2 * PI )*SPEED_LIMIT
	show_danger_pointer(show_dp)
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
		get_tree().current_scene.ball_end(self)

func _process(delta: float) -> void:
	var node_list = get_tree().current_scene.get_near_nodes(position, 100)
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
		get_tree().current_scene.fire_bullet(team, position, v)

	var dst = AI.do_fire_homming(team,delta,danger_dict,get_ball_list.call())
	if dst != null :
		get_tree().current_scene.fire_homming(team, position, dst)

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
