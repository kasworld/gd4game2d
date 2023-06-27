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
	nc.visible = true
	$CloudContainer.add_child(nc)

@onready var ball_radius :float = ball_scene.instantiate().get_radius()

func _ready():
	randomize()

	for i in range(10):
		new_cloud()

#	for t in range(2):
	for t in range(Team.Type.LEN):
		ball_spawn_effect(t % Team.Type.LEN)

func ball_spawn_effect(t :Team.Type):
	var vpsize = get_viewport_rect().size
	var p = Vector2(randf_range(ball_radius*3,vpsize.x-ball_radius*3),randf_range(ball_radius*3,vpsize.y-ball_radius*3))
	var bse = ball_spawn_sprite.instantiate()
	$EffectContainer.add_child(bse)
	bse.ended.connect(new_ball)
	bse.spawn(t,p)

func new_ball(t :Team.Type, p :Vector2):
	call_deferred("new_ball_defered",t,p)

func new_ball_defered(t :Team.Type, p :Vector2):
	var nb = ball_scene.instantiate()
	$BallContainer.add_child(nb)
	nb.fire_bullet.connect(fire_bullet)
	nb.fire_homming.connect(fire_homming)
	nb.shield_ended.connect(bullet_explode_effect)
	nb.ended.connect(ball_explode_effect)
	nb.spawn(t,p)

func ball_explode_effect(t :Team.Type, p :Vector2):
	var bee = ball_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.ended.connect(ball_spawn_effect)
	bee.spawn(t,p)

func fire_bullet(t :Team.Type, p :Vector2, v :Vector2):
	var dst = find_other_team_ball(t)
	if dst.team == t:
		return
	v = dst.position - p

#	var rad = Team.calc_aim_angle(p, 300.0, dst.position, dst.velocity )
#	v = Vector2.RIGHT.rotated(rad)
	var bl = bullet_scene.instantiate()
	$BulletContainer.add_child(bl)
	bl.ended.connect(bullet_explode_effect)
	bl.spawn(t,p,v)

func find_other_team_ball(t :Team.Type)->Ball:
	var ball_list = $BallContainer.get_children()
	var dst :Ball
	var try = 10
	while try > 0 :
		dst = ball_list.pick_random()
		if dst.team != t:
			break
		try -= 1
	return dst

func fire_homming(t :Team.Type, p :Vector2, dst :Ball):
#	var dst :Ball
	dst = find_other_team_ball(t)
	if dst.team == t: # no team kill
		return
	var hbl = homming_bullet_scene.instantiate()
	$BulletContainer.add_child(hbl)
	hbl.ended.connect(bullet_explode_effect)
	hbl.spawn(t,p,dst)

func bullet_explode_effect(p :Vector2):
	var bee = bullet_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.spawn(p)
