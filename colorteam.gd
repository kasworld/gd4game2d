class_name ColorTeam

enum Stat {
	ACCEL,
	NEW_BALL,
	NEW_SHIELD,
	NEW_BULLET,
	NEW_HOMMING,
	KILL_BALL,
	KILL_SHIELD,
	KILL_BULLET,
	KILL_HOMMING,
}

static func stat_string(k :Stat)->String:
	return Stat.keys()[k]

var color_index :int
var color :Color
var name :String
var stats :Dictionary # key string -> int
var labels :Dictionary # key string -> Label at HUD

func inc_stat(k :Stat):
	var ks = ColorTeam.stat_string(k)
	stats[ks] +=  1
	labels[ks].text = str(stats[ks])

func _init(ci :int):
	color_index = ci
	color = NamedColorList.get_color(color_index)
	name = NamedColorList.get_colorname(color_index)
	for k in Stat.keys():
		stats[k] = 0

static func make_colorteam_list(team_count :int)->Array[ColorTeam]:
	var in_use_index = {}
	var rtn :Array[ColorTeam] = []
	var color_count = NamedColorList.color_list.size()
	for t in team_count:
		var try_color_index :int
		var try_count = 10
		while true:
			try_color_index = randi() % color_count
			if in_use_index.get(try_color_index) == null :
				break
			try_count -= 1
			assert(try_count>=0)
			if try_count < 0:
				print_debug("too many retry")
				break
		in_use_index[try_color_index] = true
		var ct = ColorTeam.new(try_color_index)
		rtn.append(ct)
#		print("%s %s %s %s" % [t, ct.color_index, ct.color, ct.name])
	return rtn
