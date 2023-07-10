class_name ColorTeam

#enum Type {
#	NONE =-1,
#	BLUE,
#	GREEN,
#	BLACK,
#	ORANGE,
#	PURPLE,
#	RED,
#	WHITE,
#	YELLOW,
#	LEN,
#}
#
#static func Name(t :Type) ->String:
#	return Type.keys()[t+1]
#
#const TeamColor = {
#	Type.BLUE : Color.BLUE,
#	Type.GREEN : Color.GREEN,
#	Type.BLACK : Color.BLACK,
#	Type.ORANGE : Color.ORANGE,
#	Type.PURPLE : Color.PURPLE,
#	Type.RED : Color.RED,
#	Type.WHITE : Color.WHITE,
#	Type.YELLOW : Color.YELLOW,
#}

const TEAM_COUNT = 8

var color_index :int
var color :Color
var name :String

# return list of named color index
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

