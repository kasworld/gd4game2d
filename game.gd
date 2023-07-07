extends Node2D

var ball_scene = preload("res://ball.tscn")
var ball_spawn_sprite = preload("res://ball_spawn_sprite.tscn")
var ball_explode_sprite = preload("res://ball_explode_effect.tscn")

var bullet_scene = preload("res://bullet.tscn")
var bullet_explode_sprite = preload("res://bullet_explode_effect.tscn")

var homming_bullet_scene = preload("res://homming_bullet.tscn")
var homming_explode_sprite = preload("res://homming_explode_effect.tscn")

var cloud_scene = preload("res://cloud.tscn")

func inc_team_stat(team : Team.Type, statname: String)->void:
	$UILayer/HUD.inc_stat(team,statname)

func _ready():
	randomize()
	$UILayer/HUD.init_stat()

	for i in range(100):
		$CloudContainer.add_child(cloud_scene.instantiate())

#	for t in range(2):
#		ball_spawn_effect(t)
	add_full_team()

var team_to_add = 0
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
	var bse = ball_spawn_sprite.instantiate()
	$EffectContainer.add_child(bse)
	bse.ended.connect(new_ball)
	var vp = get_viewport_rect().size
	var p = Vector2(randf_range(0,vp.x),randf_range(0,vp.y))
	bse.spawn(t,p)

func new_ball(t :Team.Type, p :Vector2):
	new_ball_defered.call_deferred(t,p)

func new_ball_defered(t :Team.Type, p :Vector2):
	inc_team_stat(t,"new_ball")
	var nb = ball_scene.instantiate()
	$BallContainer.add_child(nb)
	nb.fire_bullet.connect(fire_bullet)
	nb.fire_homming.connect(fire_homming)
	nb.shield_ended.connect(bullet_explode_effect)
	nb.ended.connect(ball_explode_effect)
	nb.inc_team_stat.connect(inc_team_stat)
	nb.spawn(t,p)

func ball_explode_effect(t :Team.Type, p :Vector2):
	var bee = ball_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.ended.connect(ball_spawn_effect)
	bee.spawn(t,p)

func fire_bullet(t :Team.Type, p :Vector2, v :Vector2):
	inc_team_stat(t,"new_bullet")
	var bl = bullet_scene.instantiate()
	$BulletContainer.add_child(bl)
	bl.ended.connect(bullet_explode_effect)
	bl.inc_team_stat.connect(inc_team_stat)
	bl.spawn(t,p,v)

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

func fire_homming(t :Team.Type, p :Vector2, dst :Ball):
	inc_team_stat(t,"new_homming")
	var hbl = homming_bullet_scene.instantiate()
	$HommingContainer.add_child(hbl)
	hbl.ended.connect(homming_explode_effect)
	hbl.inc_team_stat.connect(inc_team_stat)
	hbl.spawn(t,p,dst)

func bullet_explode_effect(t :Team.Type, p :Vector2):
	var bee = bullet_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.spawn(t, p)

func homming_explode_effect(t :Team.Type, p :Vector2):
	var bee = homming_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.spawn(t, p)


func _on_stat_timer_timeout() -> void:
	$UILayer/HUD.ball_count = $BallContainer.get_child_count()
	$UILayer/HUD.bullet_count = $BulletContainer.get_child_count()
	$UILayer/HUD.homming_count = $HommingContainer.get_child_count()
	var shield_count = 0
	for b in $BallContainer.get_children():
		shield_count += b.shield_count
	$UILayer/HUD.shield_count = shield_count
