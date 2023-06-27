extends Node2D


var ball_scene = preload("res://ball.tscn")
var cloud_scene = preload("res://cloud.tscn")
var bullet_scene = preload("res://bullet.tscn")
var ball_spawn_sprite = preload("res://ball_spawn_sprite.tscn")
var ball_explode_sprite = preload("res://ball_explode_effect.tscn")
var bullet_explode_sprite = preload("res://bullet_explode_effect.tscn")

func new_cloud():
	var nc = cloud_scene.instantiate()
	nc.visible = true
	$CloudContainer.add_child(nc)

func _ready():
	randomize()

	for i in range(10):
		new_cloud()

	for c in range(16*2):
		ball_spawn_effect(c)

func ball_spawn_effect(c:int):
	var vpsize = get_viewport_rect().size
	var p = Vector2(randf_range(10,vpsize.x-10),randf_range(10,vpsize.y-10))
	var bse = ball_spawn_sprite.instantiate()
	$EffectContainer.add_child(bse)
	bse.ended.connect(new_ball)
	bse.spawn(c,p)

func new_ball(c:int, p :Vector2):
	call_deferred("new_ball_defered",c,p)

func new_ball_defered(c:int, p :Vector2):
	var nb = ball_scene.instantiate()
	$BallContainer.add_child(nb)
	nb.fire_bullet.connect(fire_bullet)
	nb.ended.connect(ball_explode_effect)
	nb.spawn(c,p)

func ball_explode_effect(c:int, p :Vector2):
	var bee = ball_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.ended.connect(ball_spawn_effect)
	bee.spawn(c,p)

func fire_bullet(c :int, p :Vector2, v :Vector2):
	var bl = bullet_scene.instantiate()
	$BulletContainer.add_child(bl)
	bl.ended.connect(bullet_explode_effect)
	bl.spawn(c,p,v)

func bullet_explode_effect(p :Vector2):
	var bee = bullet_explode_sprite.instantiate()
	$EffectContainer.add_child(bee)
	bee.spawn(p)
