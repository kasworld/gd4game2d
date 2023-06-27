class_name Wall extends Area2D

func set_ab(o, v1,v2):
	o.shape.a = v1
	o.shape.b = v2

func _ready() -> void:
	var vp = get_viewport_rect().size
	set_ab($Top, Vector2(0,0), Vector2(vp.x,0) )
	set_ab($Bottom, Vector2(0,vp.y), Vector2(vp.x,vp.y) )
	set_ab($Left, Vector2(0,0), Vector2(0,vp.y) )
	set_ab($Right, Vector2(vp.x,0), Vector2(vp.x,vp.y) )
