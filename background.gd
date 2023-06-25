extends ParallaxBackground


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var scrollDir = 0 # radian


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randf() > 0.9 :
		scrollDir += (randf()-0.5)/2
	scroll_offset.x +=  delta *100* sin(scrollDir)
	scroll_offset.y +=  delta *100* cos(scrollDir)
