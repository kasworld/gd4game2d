extends Node2D

var ball_scene = preload("res://ball.tscn")
var ball_spawn_scene = preload("res://ball_spawn_sprite.tscn")
var ball_explode_scene = preload("res://ball_explode_effect.tscn")
var shield_explode_scene = preload("res://shield_explode_effect.tscn")
var bullet_scene = preload("res://bullet.tscn")
var bullet_explode_scene = preload("res://bullet_explode_effect.tscn")
var homming_scene = preload("res://homming_bullet.tscn")
var homming_explode_scene = preload("res://homming_explode_effect.tscn")

var vp_rect :Rect2
var colorteam_list :Array[ColorTeam]
var life_start :float

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
	var team_count = get_team_count()
	var ball_per_team = get_ball_per_team()
	colorteam_list = ColorTeam.make_colorteam_list(team_count,ball_per_team)
	init_teamstats(colorteam_list)
	flag_apply_ball_per_team_count = true
	flag_team_count_change = false
	enable_team_ball_input(true)

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
	vp_rect = get_viewport_rect()
	$Background.init_bg(vp_rect)
	#$Background.toggle_bg()

	var cloud_count = 100
	var team_count = 3
	var ball_per_team = 1
	make_clouds(cloud_count)
	hud_init(cloud_count, team_count, ball_per_team)
	do_change_team_count()

	var msgrect = Rect2( vp_rect.size.x * 0.2 ,vp_rect.size.y * 0.4 , vp_rect.size.x * 0.6 , vp_rect.size.y * 0.2   )
	$TimedMessage.init(msgrect.size.y /5, msgrect, tr("gd4game2d 3.0.0"))
	$TimedMessage.show_message("Copyright 2023 SeukWon Kang (kasworld@gmail.com)")

func build_space_partition()->SpacePartition:
	sp.make(vp_rect, [
		$BallContainer.get_children(),
		$BulletContainer.get_children(),
		$HommingContainer.get_children(),
	])
	return sp

var sp = SpacePartition.new()
func get_near_nodes(p :Vector2, r :float)->Array[Node]:
	return sp.find_near(p, r)

func _process(delta: float) -> void:
	if flag_team_count_change:
		if check_no_gameobject():
			do_change_team_count()
	apply_ball_per_team_count()
	build_space_partition()

var key2fn = {
	KEY_ESCAPE:_on_button_quit_pressed,
	KEY_R:_on_button_restart_pressed,
	KEY_H:_on_button_hud_pressed,
	KEY_C:_on_button_cloud_pressed,
	KEY_B:_on_button_background_pressed,
	KEY_D:_on_button_danger_line_pressed,
}

func _on_button_quit_pressed() -> void:
	get_tree().quit()

func _on_button_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_button_hud_pressed() -> void:
	$HUD.visible = not $HUD.visible

func _on_button_cloud_pressed() -> void:
	$CloudContainer.visible = not $CloudContainer.visible

func _on_button_background_pressed() -> void:
	$Background.toggle_bg()

func _on_button_danger_line_pressed() -> void:
	view_dangerlines = not view_dangerlines
	$BallContainer.get_children().all(show_danger_pointer)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

var view_dangerlines = true
func show_danger_pointer(o):
	o.show_danger_pointer(view_dangerlines)
	return true

func ball_spawn_effect(t :ColorTeam):
	var obj = ball_spawn_scene.instantiate()
	$EffectContainer.add_child(obj)
	t.inc_ball_count()
	var p = Vector2(randf_range(vp_rect.position.x,vp_rect.end.x),randf_range(vp_rect.position.y,vp_rect.end.y))
	obj.spawn(t,p)

func ball_spawn_effect_end(o :BallSpawnSprite):
	$EffectContainer.remove_child(o)
	o.queue_free()

	var obj = ball_scene.instantiate()
	$BallContainer.add_child(obj)
	obj.spawn(o.team,o.position,view_dangerlines)

func ball_end(o:Ball):
	$BallContainer.remove_child.call_deferred(o)
	o.queue_free()

	var obj = ball_explode_scene.instantiate()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.position)

func ball_explode_effect_end(o :BallExplodeSprite):
	$EffectContainer.remove_child(o)
	o.queue_free()
	o.team.dec_ball_count()
	flag_apply_ball_per_team_count = true

func shield_explode_effect(o :Shield):
	var obj = shield_explode_scene.instantiate()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.global_position)

func shield_explode_effect_end(o :ShieldExplodeSprite):
	$EffectContainer.remove_child(o)
	o.queue_free()

func fire_bullet(t :ColorTeam, p :Vector2, v :Vector2):
	var obj = bullet_scene.instantiate()
	$BulletContainer.add_child(obj)
	obj.spawn(t,p,v)

func bullet_end(o :Bullet):
	$BulletContainer.remove_child.call_deferred(o)
	o.queue_free()

	var obj = bullet_explode_scene.instantiate()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.position)

func bullet_explode_effect_end(o :BulletExplodeSprite):
	$EffectContainer.remove_child(o)
	o.queue_free()

func fire_homming(t :ColorTeam, p :Vector2, dst :Area2D):
	var obj = homming_scene.instantiate()
	$HommingContainer.add_child(obj)
	obj.spawn(t,p,dst)

func homming_end(o:HommingBullet):
	$HommingContainer.remove_child.call_deferred(o)
	o.queue_free()

	var obj = homming_explode_scene.instantiate()
	$EffectContainer.add_child(obj)
	obj.spawn(o.team,o.position)

func homming_explode_effect_end(o :HommingExplodeSprite):
	$EffectContainer.remove_child(o)
	o.queue_free()

func get_ball_list()->Array:
	return $BallContainer.get_children()

func _on_stat_timer_timeout() -> void:
	set_game_stat("GameSec", Time.get_unix_time_from_system() - life_start)
	set_game_stat("FPS", Performance.get_monitor(Performance.TIME_FPS))

	set_game_stat("Ball", $BallContainer.get_child_count())
	set_game_stat("Bullet", $BulletContainer.get_child_count())
	set_game_stat("Homming", $HommingContainer.get_child_count())
	set_game_stat("Explosion", $EffectContainer.get_child_count())
	var shield_count = 0
	for b in $BallContainer.get_children():
		shield_count += b.get_shield_count()
	set_game_stat("Shield", shield_count )

################## hud ##################
func _on_cloud_count_value_changed(idx) -> void:
	var v = get_cloud_count()
	make_clouds(v)

var flag_team_count_change :bool
func _on_team_count_value_changed(idx) -> void:
	make_no_gameobject()
	flag_team_count_change = true
	enable_team_ball_input(false)

func _on_ball_per_team_value_changed(idx) -> void:
	var v = get_ball_per_team()
	for t in colorteam_list:
		t.set_ball_count_limit(v)
	flag_apply_ball_per_team_count = true

func get_cloud_count()->int:
	return $HUD/CountContainer/CloudCount.get_value()

func get_team_count()->int:
	return $HUD/CountContainer/TeamCount.get_value()

func get_ball_per_team()->int:
	return $HUD/CountContainer/BallPerTeam.get_value()

func hud_init(cloud_count :int,team_count :int, ball_per_team:int):
	init_game_stat()

	$HUD/CountContainer.theme.default_font_size = vp_rect.size.y / 32
	$HUD/CountContainer/CloudCount.init(0, "Cloud count(0-999)", vp_rect.size.y / 32)
	$HUD/CountContainer/CloudCount.set_limits(0, true,cloud_count, 999, true)
	$HUD/CountContainer/TeamCount.init(1,"Team count(0-100)", vp_rect.size.y / 32)
	$HUD/CountContainer/TeamCount.set_limits(1,true, team_count, 100, true)
	$HUD/CountContainer/BallPerTeam.init(2, "Balls / team(0-200)", vp_rect.size.y / 32)
	$HUD/CountContainer/BallPerTeam.set_limits(0,true, ball_per_team, 200, true)
	hud_set_pos.call_deferred()

func hud_set_pos()->void:
	$HUD/GameStats.position.x = vp_rect.size.x - $HUD/GameStats.size.x
	$HUD/CountContainer.position = vp_rect.size - $HUD/CountContainer.size

func enable_team_ball_input(b :bool):
	$HUD/CountContainer/TeamCount.disable_buttons(not b)
	$HUD/CountContainer/BallPerTeam.disable_buttons(not b)

func init_teamstats(colorteam_list :Array[ColorTeam]):
	for o in $HUD/TeamStatGrid.get_children():
		$HUD/TeamStatGrid.remove_child(o)
	$HUD/TeamStatGrid.columns = ColorTeam.Stat.keys().size() + 1

	var header_label_settings = LabelSettings.new()
	header_label_settings.outline_size = 2
	header_label_settings.font_color = Color.WHITE
	header_label_settings.outline_color = Color.BLACK
	header_label_settings.font_size = vp_rect.size.y / 50

	add_header(header_label_settings)
	for t in colorteam_list:
		t.name_label.label_settings.font_size = vp_rect.size.y / 50
		$HUD/TeamStatGrid.add_child(t.name_label)
		for k in t.labels:
			var lb = t.labels[k]
			lb.label_settings.font_size = vp_rect.size.y / 50
			$HUD/TeamStatGrid.add_child(lb)
	add_header(header_label_settings)

func add_header(lbs :LabelSettings):
	add_label_to_teamstat("team",lbs)
	for s in ColorTeam.Stat.keys():
		add_label_to_teamstat(s.to_lower()+" ",lbs)

func add_label_to_teamstat(s :String, lbs :LabelSettings)->Label:
	var lb = Label.new()
	lb.text = s
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.label_settings = lbs
	$HUD/TeamStatGrid.add_child(lb)
	return lb

func init_game_stat():
	var lbset = LabelSettings.new()
	lbset.font_size = vp_rect.size.y / 30
	lbset.font_color = Color.WHITE
	lbset.outline_size = 2
	lbset.outline_color = Color.BLACK
	for s in GameStatName.keys():
		var lb = Label.new()
		lb.label_settings = lbset
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		game_stat_label[s] = lb
		$HUD/GameStats.add_child(lb)
		set_game_stat(s,0)

const GameStatName = {
	"GameSec" :"%04.2f",
	"FPS" :"%04.2f",
	"Ball" :"%d",
	"Shield" :"%d",
	"Bullet" :"%d",
	"Homming" :"%d",
	"Explosion" :"%d",
}
var game_stat_label :Dictionary

func set_game_stat(n :String, v):
	game_stat_label[n].text = "{0} : {1}".format( [n , GameStatName[n] % v ] )

