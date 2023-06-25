extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vprt = get_viewport_rect()
	position.x =  randi_range(0,vprt.size.x)
	position.y =  randi_range(0,vprt.size.y)
	$CloudSprites.frame = randi_range(0,3)
	if randi_range(0,1) == 0 :
		$CloudSprites.flip_h = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.
