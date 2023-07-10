class_name ColorTeam

const TEAM_COUNT = 8

var color_index :int
var color :Color
var name :String

static func make_color_teamlist()->Array[ColorTeam]:
	var rtn :Array[ColorTeam]
	var color_count =NamedColorList.color_list.size()
	for t in TEAM_COUNT:
		var ct = ColorTeam.new()
		ct.color_index = randi() % color_count
		ct.name = NamedColorList.get_colorname(ct.color_index)
		ct.color = NamedColorList.get_color(ct.color_index)
		rtn.append(ct)
	return rtn
