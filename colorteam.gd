class_name ColorTeam

var color_index :int
var color :Color
var name :String

static func make_color_teamlist(team_count :int)->Array[ColorTeam]:
	var in_use_index = {}
	var rtn :Array[ColorTeam]
	var color_count = NamedColorList.color_list.size()
	for t in team_count:
		var ct = ColorTeam.new()
		var try_color_index :int
		var try_count = 10
		while true:
			try_color_index = randi() % color_count
			if in_use_index.get(try_color_index) == null :
				break
			try_count -= 1
			if try_count < 0:
				print("too many retry")
				break
		in_use_index[try_color_index] = true
		ct.color_index = try_color_index
		ct.name = NamedColorList.get_colorname(ct.color_index)
		ct.color = NamedColorList.get_color(ct.color_index)
		rtn.append(ct)
	return rtn
