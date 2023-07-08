extends Node2D

var ball_scene = preload("res://ball.tscn")
var ball_spawn_sprite = preload("res://ball_spawn_sprite.tscn")
var ball_explode_sprite = preload("res://ball_explode_effect.tscn")

var bullet_scene = preload("res://bullet.tscn")
var bullet_explode_sprite = preload("res://bullet_explode_effect.tscn")

var homming_scene = preload("res://homming_bullet.tscn")
var homming_explode_sprite = preload("res://homming_explode_effect.tscn")

var cloud_scene = preload("res://cloud.tscn")

var ball_free_list :Node2DPool
var ball_spawn_free_list :Node2DPool
var ball_explode_free_list :Node2DPool

var bullet_free_list :Node2DPool
var bullet_explode_free_list :Node2DPool

var homming_free_list :Node2DPool
var homming_explode_free_list :Node2DPool


func inc_team_stat(team : Team.Type, statname: String)->void:
	$UILayer/HUD.inc_stat(team,statname)

func _ready():
	randomize()
	ball_free_list = Node2DPool.new(ball_scene.instantiate)
	ball_spawn_free_list = Node2DPool.new(ball_spawn_sprite.instantiate)
	ball_explode_free_list = Node2DPool.new(ball_explode_sprite.instantiate)
	bullet_free_list = Node2DPool.new(bullet_scene.instantiate)
	bullet_explode_free_list = Node2DPool.new(bullet_explode_sprite.instantiate)
	homming_free_list = Node2DPool.new(homming_scene.instantiate)
	homming_explode_free_list = Node2DPool.new(homming_explode_sprite.instantiate)

	$UILayer/HUD.init_stat()

	for i in range(100):
		$CloudContainer.add_child(cloud_scene.instantiate())

#	for t in range(2):
#		ball_spawn_effect(t)
	add_full_team()

var team_to_add = 10
func rand_per_sec(delta :float, per_sec :float)->bool:
	return randf() < per_sec*delta
func _process(delta: float) -> void:
	if team_to_add > 0 and rand_per_sec(delta, 1):
		team_to_add -= 1
		add_full_team()

func add_full_team():
	for t in range(Team.Type.LEN):
		ball_spawn_effect(t)

func ball_spawn_effect(t :Team.Type):
	var obj = ball_spawn_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	if not obj.ended.is_connected(new_ball):
		obj.ended.connect(new_ball)
	var vp = get_viewport_rect().size
	var p = Vector2(randf_range(0,vp.x),randf_range(0,vp.y))
	obj.spawn(t,p)

func new_ball(o :BallSpawnSprite):
	ball_spawn_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)
	new_ball_defered.call_deferred(o.team,o.position)

func new_ball_defered(t :Team.Type, p :Vector2):
	inc_team_stat(t,"new_ball")
	var obj = ball_scene.instantiate()
	$BallContainer.add_child(obj)
	if not obj.fire_bullet.is_connected(fire_bullet):
		obj.fire_bullet.connect(fire_bullet)
	if not obj.fire_homming.is_connected(fire_homming):
		obj.fire_homming.connect(fire_homming)
	if not obj.shield_ended.is_connected(bullet_explode_effect):
		obj.shield_ended.connect(bullet_explode_effect)
	if not obj.ended.is_connected(ball_explode_effect):
		obj.ended.connect(ball_explode_effect)
	if not obj.inc_team_stat.is_connected(inc_team_stat):
		obj.inc_team_stat.connect(inc_team_stat)
	obj.spawn(t,p)

func ball_explode_effect(t :Team.Type, p :Vector2):
	var obj = ball_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	if not obj.ended.is_connected(ball_explode_effect_end):
		obj.ended.connect(ball_explode_effect_end)
	obj.spawn(t,p)

func ball_explode_effect_end(o :BallExplodeSprite):
	ball_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)
	ball_spawn_effect(o.team)

func fire_bullet(t :Team.Type, p :Vector2, v :Vector2):
	inc_team_stat(t,"new_bullet")
	var obj = bullet_scene.instantiate()
	$BulletContainer.add_child(obj)
	if not obj.ended.is_connected(bullet_explode_effect):
		obj.ended.connect(bullet_explode_effect)
	if not obj.inc_team_stat.is_connected(inc_team_stat):
		obj.inc_team_stat.connect(inc_team_stat)
	obj.spawn(t,p,v)

func bullet_explode_effect(t :Team.Type, p :Vector2):
	var obj = bullet_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	if not obj.ended.is_connected(bullet_explode_effect_end):
		obj.ended.connect(bullet_explode_effect_end)
	obj.spawn(t, p)

func bullet_explode_effect_end(o :BulletExplodeSprite):
	bullet_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func fire_homming(t :Team.Type, p :Vector2, dst :Ball):
	inc_team_stat(t,"new_homming")
	var obj = homming_scene.instantiate()
	$HommingContainer.add_child(obj)
	if not obj.ended.is_connected(homming_explode_effect):
		obj.ended.connect(homming_explode_effect)
	if not obj.inc_team_stat.is_connected(inc_team_stat):
		obj.inc_team_stat.connect(inc_team_stat)
	obj.spawn(t,p,dst)

func homming_explode_effect(o :HommingBullet):
	var obj = homming_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	if not obj.ended.is_connected(homming_explode_effect_end):
		obj.ended.connect(homming_explode_effect_end)
	obj.spawn(o.team,o.position)

func homming_explode_effect_end(o :HommingExplodeSprite):
	homming_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func find_other_team_ball(t :Team.Type)->Ball:
	var ball_list = $BallContainer.get_children()
	if ball_list.size() == 0:
		return null
	var dst :Ball
	var try = 10
	while try > 0 :
		dst = ball_list.pick_random()
		if dst != null and dst.alive and dst.team != t:
			break
		try -= 1
	return dst

func _on_stat_timer_timeout() -> void:
	$UILayer/HUD.ball_count = $BallContainer.get_child_count()
	$UILayer/HUD.bullet_count = $BulletContainer.get_child_count()
	$UILayer/HUD.homming_count = $HommingContainer.get_child_count()
	var shield_count = 0
	for b in $BallContainer.get_children():
		shield_count += b.shield_count
	$UILayer/HUD.shield_count = shield_count
