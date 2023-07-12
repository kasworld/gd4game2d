extends Node2D

var ball_free_list := Node2DPool.new(preload("res://ball.tscn").instantiate)
var ball_spawn_free_list = Node2DPool.new(preload("res://ball_spawn_sprite.tscn").instantiate)
var ball_explode_free_list = Node2DPool.new(preload("res://ball_explode_effect.tscn").instantiate)
var shield_explode_free_list = Node2DPool.new(preload("res://shield_explode_effect.tscn").instantiate)
var bullet_free_list = Node2DPool.new(preload("res://bullet.tscn").instantiate)
var bullet_explode_free_list = Node2DPool.new(preload("res://bullet_explode_effect.tscn").instantiate)
var homming_free_list = Node2DPool.new(preload("res://homming_bullet.tscn").instantiate)
var homming_explode_free_list = Node2DPool.new(preload("res://homming_explode_effect.tscn").instantiate)

var background :Background
var vp_size :Vector2
var colorteam_list :Array[ColorTeam]
var life_start :float

func inc_team_stat(team : ColorTeam, statname: String)->void:
	$UILayer/HUD.inc_team_stat(team,statname)

func _ready():
	randomize()
	life_start = Time.get_unix_time_from_system()

	vp_size = get_viewport_rect().size

	background = preload("res://background.tscn").instantiate()
	background.init_bg(vp_size)
	add_child(background)

	for i in range(100):
		$CloudContainer.add_child(preload("res://cloud.tscn").instantiate())

	colorteam_list = ColorTeam.make_color_teamlist(30)
	for i in 1:
		add_full_team()

	$UILayer/HUD.init_stat(vp_size, colorteam_list)

var fps :float
func _process(delta: float) -> void:
	handle_input()
	fps = (fps+1.0/delta)/2

func handle_input():
	if Input.is_action_just_pressed("HUD"):
		$UILayer.visible = not $UILayer.visible
	if Input.is_action_just_pressed("Background"):
		background.toggle_bg()
	if Input.is_action_just_pressed("Cloud"):
		$CloudContainer.visible = not $CloudContainer.visible
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()

func add_full_team():
	for t in colorteam_list:
		ball_spawn_effect(t)

func ball_spawn_effect(t :ColorTeam):
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

func new_ball_defered(t :ColorTeam, p :Vector2):
	inc_team_stat(t,"new_ball")
	var obj = ball_free_list.get_node2d()
	$BallContainer.add_child(obj)
	connect_if_not(obj.fire_bullet,fire_bullet)
	connect_if_not(obj.fire_homming,fire_homming)
	connect_if_not(obj.shield_ended_from_ball,shield_explode_effect)
	connect_if_not(obj.ended,ball_end)
	obj.spawn(t,p, inc_team_stat)

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

func shield_explode_effect_end(o :ShieldExplodeSprite):
	shield_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func fire_bullet(t :ColorTeam, p :Vector2, v :Vector2):
	inc_team_stat(t,"new_bullet")
	var obj = bullet_free_list.get_node2d()
	$BulletContainer.add_child(obj)
	connect_if_not(obj.ended,bullet_end)
	obj.spawn(t,p,v, inc_team_stat)

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

func fire_homming(t :ColorTeam, p :Vector2, dst :Ball):
	inc_team_stat(t,"new_homming")
	var obj = homming_free_list.get_node2d()
	$HommingContainer.add_child(obj)
	connect_if_not(obj.ended,homming_end)
	obj.spawn(t,p,dst,inc_team_stat)

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

func find_other_team_ball(t :ColorTeam)->Ball:
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

func update_game_stat():
	$UILayer/HUD.set_game_stat("Ball", $BallContainer.get_child_count())
	$UILayer/HUD.set_game_stat("Bullet", $BulletContainer.get_child_count())
	$UILayer/HUD.set_game_stat("Homming", $HommingContainer.get_child_count())
	$UILayer/HUD.set_game_stat("Explosion", $EffectContainer.get_child_count())
	var shield_count = 0
	for b in $BallContainer.get_children():
		shield_count += b.get_shield_count()
	$UILayer/HUD.set_game_stat("Shield", shield_count )

func _on_stat_timer_timeout() -> void:
	$UILayer/HUD.set_game_stat("GameSec", Time.get_unix_time_from_system() - life_start)
	$UILayer/HUD.set_game_stat("FPS", fps)
	update_game_stat()
