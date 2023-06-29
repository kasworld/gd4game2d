class_name Team extends Object

enum Type {
	NONE =-1,
	BLUE,
	GREEN,
	GREY,
	ORANGE,
	PURPLE,
	RED,
	WHITE,
	YELLOW,
	LEN,
}

var stat_list :Array[Stat]


# struct for stat data
class Stat:
	# my team spawn
	var new_ball_count :int
	var new_shield_count :int
	var new_bullet_count :int
	var new_homming_count :int
	# kill other team
	var kill_ball_count :int
	var kill_shield_count :int
	var kill_bullet_count :int
	var kill_homming_count :int
	# change direction
	var accel_count :int

func _init() -> void:
	for t in Type.LEN:
		var s = Stat.new()
		stat_list.append(s)
#		print( str(t),s)
