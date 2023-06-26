extends ParallaxBackground

var scrollDir = 0 # radian

func _process(delta):
	if randf() > 0.9 :
		scrollDir += (randf()-0.5)/2
	scroll_offset.x +=  delta *100* sin(scrollDir)
	scroll_offset.y +=  delta *100* cos(scrollDir)
