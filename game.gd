extends Node2D

var ball_scene = preload("res://ball.tscn")
var ball_spawn_sprite = preload("res://ball_spawn_sprite.tscn")
var ball_explode_sprite = preload("res://ball_explode_effect.tscn")

var bullet_scene = preload("res://bullet.tscn")
var bullet_explode_sprite = preload("res://bullet_explode_effect.tscn")

var homming_bullet_scene = preload("res://homming_bullet.tscn")

var cloud_scene = preload("res://cloud.tscn")

func new_cloud():
	var nc = cloud_scene.instantiate()
	$CloudContainer.add_child(nc)

func inc_team_stat(team : Team.Type, statname: String)->void:
	$UILayer/HUD.inc_stat(team,statname)

var make_spawn_pos :Callable

func _ready():
	randomize()
	$UILayer/HUD.init_stat()

	# for make pos only
	var nb = ball_scene.instantiate()
	add_child(nb)
	make_spawn_pos = nb.make_spawn_pos

	for i in range(10):
		new_cloud()

#	for t in range(2):
	for t in range(Team.Type.LEN):
		ball_spawn_effect(t % Team.Type.LEN)

func ball_spawn_effect(t :Team.Type):
	var bse = ball_spawn_sprite.instantiate()
	$EffectContainer.add_child(bse)
	bse.ended.connect(new_ball)
	var p = make_spawn_pos.call()
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
	$BulletContainer.add_child(hbl)
	hbl.ended.connect(bullet_explode_effect)
	hbl.inc_team_stat.connect(inc_team_stat)
	hbl.spawn(t,p,dst)

func bullet_explode_effect(p :Vector2):
	var bee = bullet_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.spawn(p)
