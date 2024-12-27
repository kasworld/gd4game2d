class_name Background extends ParallaxBackground

var vp_rect :Rect2
var bg_state :int

func init_bg(rt :Rect2) -> void:
	vp_rect = rt
	$ColorRect.size = vp_rect.size

var bg_colors = [
	Color.BLACK,
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.CYAN,
	Color.MAGENTA,
	Color.YELLOW,
	Color.WHITE,
]

func toggle_bg():
	bg_state += 1
	bg_state %= bg_colors.size()
	$ColorRect.color = bg_colors[bg_state]
