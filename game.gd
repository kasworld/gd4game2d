extends Node2D

var ball_scene = preload("res://ball.tscn")
var ball_spawn_sprite = preload("res://ball_spawn_sprite.tscn")
var ball_explode_sprite = preload("res://ball_explode_effect.tscn")

var bullet_scene = preload("res://bullet.tscn")
var bullet_explode_sprite = preload("res://bullet_explode_effect.tscn")

var homming_scene = preload("res://homming_bullet.tscn")
var homming_explode_sprite = preload("res://homming_explode_effect.tscn")

var cloud_scene = preload("res://cloud.tscn")

var background_scene = preload("res://background.tscn")

var ball_free_list :Node2DPool
var ball_spawn_free_list :Node2DPool
var ball_explode_free_list :Node2DPool

var bullet_free_list :Node2DPool
var bullet_explode_free_list :Node2DPool

var shield_explode_free_list :Node2DPool

var homming_free_list :Node2DPool
var homming_explode_free_list :Node2DPool

var background :Background

func inc_team_stat(team : Team.Type, statname: String)->void:
	$UILayer/HUD.inc_stat(team,statname)

func add_background():
	background = background_scene.instantiate()
	background.vp_size = get_viewport_rect().size
	add_child(background)

func _ready():
	randomize()
	ball_free_list = Node2DPool.new(ball_scene.instantiate)
	ball_spawn_free_list = Node2DPool.new(ball_spawn_sprite.instantiate)
	ball_explode_free_list = Node2DPool.new(ball_explode_sprite.instantiate)
	bullet_free_list = Node2DPool.new(bullet_scene.instantiate)
	bullet_explode_free_list = Node2DPool.new(bullet_explode_sprite.instantiate)
	shield_explode_free_list = Node2DPool.new(bullet_explode_sprite.instantiate)
	homming_free_list = Node2DPool.new(homming_scene.instantiate)
	homming_explode_free_list = Node2DPool.new(homming_explode_sprite.instantiate)

	add_background()

	$UILayer/HUD.init_stat()

	for i in range(100):
		$CloudContainer.add_child(cloud_scene.instantiate())

#	for t in range(2):
#		ball_spawn_effect(t)
	for i in 1:
		add_full_team()

var team_to_delay_add = 0
func rand_per_sec(delta :float, per_sec :float)->bool:
	return randf() < per_sec*delta
func _process(delta: float) -> void:
	if team_to_delay_add > 0 and rand_per_sec(delta, 1):
		team_to_delay_add -= 1
		add_full_team()
	handle_input()

func handle_input():
	if Input.is_action_just_pressed("HUD"):
		$UILayer.visible = not $UILayer.visible
	if Input.is_action_just_pressed("Background"):
		background.visible = not background.visible
	if Input.is_action_just_pressed("Cloud"):
		$CloudContainer.visible = not $CloudContainer.visible

func add_full_team():
	for t in range(Team.Type.LEN):
		ball_spawn_effect(t)

func ball_spawn_effect(t :Team.Type):
	var obj = ball_spawn_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	connect_if_not(obj.ended,new_ball)
	var vp = get_viewport_rect().size
	var p = Vector2(randf_range(0,vp.x),randf_range(0,vp.y))
	obj.spawn(t,p)

func new_ball(o :BallSpawnSprite):
	ball_spawn_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)
	new_ball_defered.call_deferred(o.team,o.position)

func new_ball_defered(t :Team.Type, p :Vector2):
	inc_team_stat(t,"new_ball")
	var obj = ball_free_list.get_node2d()
	$BallContainer.add_child(obj)
	connect_if_not(obj.fire_bullet,fire_bullet)
	connect_if_not(obj.fire_homming,fire_homming)
	connect_if_not(obj.shield_ended,shield_explode_effect)
	connect_if_not(obj.ended,ball_end)
	connect_if_not(obj.inc_team_stat,inc_team_stat)
	obj.spawn(t,p)

func ball_end(o:Ball):
	ball_free_list.put_node2d(o)
	$BallContainer.remove_child.call_deferred(o)
	ball_explode_effect(o)

func ball_explode_effect(o :Ball):
	var obj = ball_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	connect_if_not(obj.ended,ball_explode_effect_end)
	obj.spawn(o.team,o.position)

func ball_explode_effect_end(o :BallExplodeSprite):
	ball_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)
	ball_spawn_effect(o.team)

func shield_explode_effect(o :Shield):
	var obj = shield_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	connect_if_not(obj.ended,shield_explode_effect_end)
	obj.spawn(o.team,o.global_position)

func shield_explode_effect_end(o :BulletExplodeSprite):
	shield_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func fire_bullet(t :Team.Type, p :Vector2, v :Vector2):
	inc_team_stat(t,"new_bullet")
	var obj = bullet_free_list.get_node2d()
	$BulletContainer.add_child(obj)
	connect_if_not(obj.ended,bullet_end)
	connect_if_not(obj.inc_team_stat,inc_team_stat)
	obj.spawn(t,p,v)

func bullet_end(o :Bullet):
	bullet_free_list.put_node2d(o)
	$BulletContainer.remove_child.call_deferred(o)
	bullet_explode_effect(o)

func bullet_explode_effect(o :Bullet):
	var obj = bullet_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	connect_if_not(obj.ended,bullet_explode_effect_end)
	obj.spawn(o.team,o.position)

func bullet_explode_effect_end(o :BulletExplodeSprite):
	bullet_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func fire_homming(t :Team.Type, p :Vector2, dst :Ball):
	inc_team_stat(t,"new_homming")
	var obj = homming_free_list.get_node2d()
	$HommingContainer.add_child(obj)
	connect_if_not(obj.ended,homming_end)
	connect_if_not(obj.inc_team_stat,inc_team_stat)
	obj.spawn(t,p,dst)

func homming_end(o:HommingBullet):
	homming_free_list.put_node2d(o)
	$HommingContainer.remove_child.call_deferred(o)
	homming_explode_effect(o)

func homming_explode_effect(o :HommingBullet):
	var obj = homming_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	connect_if_not(obj.ended,homming_explode_effect_end)
	obj.spawn(o.team,o.position)

func homming_explode_effect_end(o :HommingExplodeSprite):
	homming_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func connect_if_not(sg :Signal, fn :Callable):
	if not sg.is_connected(fn):
		sg.connect(fn)

func find_other_team_ball(t :Team.Type)->Ball:
	var ball_list = $BallContainer.get_children()
	if ball_list.size() == 0:
		return null
	var dst :Ball
	var try = 10
	while try > 0 :
		dst = ball_list.pick_random()
		if dst != null and dst.alive and dst.team != t:
			return dst
		try -= 1
	return null

func _on_stat_timer_timeout() -> void:
	$UILayer/HUD.ball_count = $BallContainer.get_child_count()
	$UILayer/HUD.bullet_count = $BulletContainer.get_child_count()
	$UILayer/HUD.homming_count = $HommingContainer.get_child_count()
	$UILayer/HUD.effect_count = $EffectContainer.get_child_count()
	var shield_count = 0
	for b in $BallContainer.get_children():
		shield_count += b.shield_count
	$UILayer/HUD.shield_count = shield_count
