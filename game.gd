extends Node2D


var ball_scene = preload("res://ball.tscn")
var cloud_scene = preload("res://cloud.tscn")
var bullet_scene = preload("res://bullet.tscn")

var clouds  = []

func new_cloud():
	var nc = cloud_scene.instantiate()
	nc.visible = true
	clouds.append(nc)
	$CloudContainer.add_child(nc)

func new_ball(c:int):
	call_deferred("new_ball_defered",c)

func new_ball_defered(c:int):
	var nb = ball_scene.instantiate()
	$BallContainer.add_child(nb)
	var vpsize = get_viewport_rect().size
	var p = Vector2(randf_range(10,vpsize.x-10),randf_range(10,vpsize.y-10))
	nb.spawn(c,p)
	nb.fire_bullet.connect(fire_bullet)
	nb.ended.connect(new_ball)

func _ready():
	randomize()

	for i in range(10):
		new_cloud()

	for c in range(16*2):
		new_ball(c)

func fire_bullet(c :int, p :Vector2, v :Vector2):
	var bl = bullet_scene.instantiate()
	$BulletContainer.add_child(bl)
	bl.spawn(c,p,v)
