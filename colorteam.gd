class_name ColorTeam

var color_index :int
var color :Color
var name :String

func _init(ci :int):
	color_index = ci
	color = NamedColorList.get_color(color_index)
	name = NamedColorList.get_colorname(color_index)

static func make_color_teamlist(team_count :int)->Array[ColorTeam]:
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
