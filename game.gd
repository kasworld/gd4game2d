extends Node2D

var ball_free_list = Node2DPool.new(preload("res://ball.tscn").instantiate)
var ball_spawn_free_list = Node2DPool.new(preload("res://ball_spawn_sprite.tscn").instantiate)
var ball_explode_free_list = Node2DPool.new(preload("res://ball_explode_effect.tscn").instantiate)
var shield_explode_free_list = Node2DPool.new(preload("res://shield_explode_effect.tscn").instantiate)
var bullet_free_list = Node2DPool.new(preload("res://bullet.tscn").instantiate)
var bullet_explode_free_list = Node2DPool.new(preload("res://bullet_explode_effect.tscn").instantiate)
var homming_free_list = Node2DPool.new(preload("res://homming_bullet.tscn").instantiate)
var homming_explode_free_list = Node2DPool.new(preload("res://homming_explode_effect.tscn").instantiate)

var vp_size :Vector2
var colorteam_list :Array[ColorTeam]
var life_start :float

func _on_hud_ball_per_team_changed(v) -> void:
	for t in colorteam_list:
		t.set_ball_count_limit(v)
	flag_apply_ball_per_team_count = true

var flag_apply_ball_per_team_count :bool
func apply_ball_per_team_count():
	if flag_apply_ball_per_team_count == false:
		return
	for t in colorteam_list:
		var tomake = t.calc_tomake_ball()
		if tomake > 0:
			for i in tomake:
				ball_spawn_effect(t) # make ball by spawn
		elif tomake < 0:
			for b in $BallContainer.get_children():
				if b.team == t:
					b.end.call_deferred()
					tomake +=1
					if tomake >=0:
						break
	flag_apply_ball_per_team_count = false

var flag_team_count_change :bool
func _on_hud_team_count_changed(_v) -> void:
	make_no_gameobject()
	flag_team_count_change = true
	$UILayer/HUD.enable_team_ball_input(false)

func make_no_gameobject():
	for t in colorteam_list:
		t.set_ball_count_limit(0)
	for b in $BallContainer.get_children():
		b.end.call_deferred()

func check_no_gameobject()->bool:
	return $BallContainer.get_child_count() == 0 and \
		$BulletContainer.get_child_count() == 0 and \
		$HommingContainer.get_child_count() == 0 and \
		$EffectContainer.get_child_count() == 0

func do_change_team_count():
	var team_count = $UILayer/HUD.get_team_count()
	var ball_per_team = $UILayer/HUD.get_ball_per_team()
	colorteam_list = ColorTeam.make_colorteam_list(team_count,ball_per_team)
	$UILayer/HUD.init_teamstats(colorteam_list)
	flag_apply_ball_per_team_count = true
	flag_team_count_change = false
	$UILayer/HUD.enable_team_ball_input(true)

func _on_hud_cloud_count_changed(v) -> void:
	make_clouds(v)

func make_clouds(cloud_count :int):
	var tomake = cloud_count - $CloudContainer.get_child_count()
	if tomake > 0:
		for i in tomake:
			$CloudContainer.add_child(preload("res://cloud.tscn").instantiate())
	elif tomake < 0:
		for o in $CloudContainer.get_children():
			o.queue_free()
			tomake +=1
			if tomake >=0:
				break

func _ready():
	randomize()
	life_start = Time.get_unix_time_from_system()
	vp_size = get_viewport_rect().size
	$Background.init_bg(vp_size)

	var cloud_count  = 100
	var team_count = 2
	var ball_per_team = 1
	make_clouds(cloud_count)
	$UILayer/HUD.init(vp_size, cloud_count, team_count, ball_per_team)
	do_change_team_count()

var fps :float
func _process(delta: float) -> void:
	handle_input()
	fps = (fps+1.0/delta)/2
	if flag_team_count_change:
		if check_no_gameobject():
			do_change_team_count()
	apply_ball_per_team_count()

func handle_input():
	if Input.is_action_just_pressed("HUD"):
		$UILayer.visible = not $UILayer.visible
	if Input.is_action_just_pressed("Background"):
		$Background.toggle_bg()
	if Input.is_action_just_pressed("Cloud"):
		$CloudContainer.visible = not $CloudContainer.visible
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()

func ball_spawn_effect(t :ColorTeam):
	var obj = ball_spawn_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	t.inc_ball_count()
	var p = Vector2(randf_range(0,vp_size.x),randf_range(0,vp_size.y))
	obj.spawn(t,p)

func ball_spawn_effect_end(o :BallSpawnSprite):
	ball_spawn_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

	var obj = ball_free_list.get_node2d()
	$BallContainer.add_child(obj)
	AI.connect_if_not(obj.ended,ball_end)
	obj.spawn(o.team,o.position)

func ball_end(o:Ball):
	ball_free_list.put_node2d(o)
	$BallContainer.remove_child.call_deferred(o)

	var obj = ball_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.position)

func ball_explode_effect_end(o :BallExplodeSprite):
	ball_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)
	o.team.dec_ball_count()
	flag_apply_ball_per_team_count = true

func shield_explode_effect(o :Shield):
	var obj = shield_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.global_position)

func shield_explode_effect_end(o :ShieldExplodeSprite):
	shield_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func fire_bullet(t :ColorTeam, p :Vector2, v :Vector2):
	var obj = bullet_free_list.get_node2d()
	$BulletContainer.add_child(obj)
	obj.spawn(t,p,v)

func bullet_end(o :Bullet):
	bullet_free_list.put_node2d(o)
	$BulletContainer.remove_child.call_deferred(o)

	var obj = bullet_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.position)

func bullet_explode_effect_end(o :BulletExplodeSprite):
	bullet_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func fire_homming(t :ColorTeam, p :Vector2, dst :Ball):
	var obj = homming_free_list.get_node2d()
	$HommingContainer.add_child(obj)
	obj.spawn(t,p,dst)

func homming_end(o:HommingBullet):
	homming_free_list.put_node2d(o)
	$HommingContainer.remove_child.call_deferred(o)

	var obj = homming_explode_free_list.get_node2d()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.position)

func homming_explode_effect_end(o :HommingExplodeSprite):
	homming_explode_free_list.put_node2d(o)
	$EffectContainer.remove_child(o)

func get_ball_list()->Array:
	return $BallContainer.get_children()

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

