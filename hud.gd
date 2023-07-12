extends Control


const TeamStatName :Array[String] = [
	"accel",
	"new_ball",
	"new_shield",
	"new_bullet",
	"new_homming",
	"kill_ball",
	"kill_shield",
	"kill_bullet",
	"kill_homming",
]
# team_stat[team_name][stat_culumn] :int
var team_stat := {}
# team_stat_label[team_name][stat_culumn] :Label
var team_stat_label := {}

var vp_size :Vector2

func init_stat(vp :Vector2, colorteam_list :Array[ColorTeam]):
	vp_size = vp

	$Help.label_settings.font_size = vp_size.y / 32

	for s in GameStatName.keys():
		game_stat_label[s] = add_label_to_gamestat(s, Color.WHITE)
		set_game_stat(s,0)

	add_label_to_teamstat("Team",Color.WHITE)
	for s in TeamStatName:
		add_label_to_teamstat(s,Color.WHITE)

	for t in colorteam_list:
		add_label_to_teamstat(t.name, t.color)
		team_stat[t.name] = {}
		team_stat_label[t.name] = {}
		for c in TeamStatName:
			team_stat[t.name][c] = 0
			var lb = add_label_to_teamstat(str(team_stat[t.name][c]) , t.color)
			team_stat_label[t.name][c] = lb

	add_label_to_teamstat("Team",Color.WHITE)
	for s in TeamStatName:
		add_label_to_teamstat(s,Color.WHITE)

func add_label_to_teamstat(s :String, c :Color)->Label:
	var lb = Label.new()
	lb.label_settings = LabelSettings.new()
	lb.text = s
	lb.label_settings.font_size = vp_size.y / 50
	lb.label_settings.font_color = c
	lb.label_settings.outline_size = 2
	lb.label_settings.outline_color = c.inverted()
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$TeamStatGrid.add_child(lb)
	return lb

func inc_team_stat(team : ColorTeam, statname: String)->void:
	team_stat[team.name][statname] += 1
	team_stat_label[team.name][statname].text = str(team_stat[team.name][statname])

const GameStatName = {
	"GameSec" :"%04.2f",
	"FPS" :"%04.2f",
	"Ball" :"%d",
	"Shield" :"%d",
	"Bullet" :"%d",
	"Homming" :"%d",
	"Explosion" :"%d",
}
var game_stat_label := {}
func add_label_to_gamestat(s :String, c :Color)->Label:
	var lb = Label.new()
	lb.text = s
	lb.label_settings = LabelSettings.new()
	lb.label_settings.font_size = vp_size.y / 30
	lb.label_settings.font_color = c
	lb.label_settings.outline_size = 2
	lb.label_settings.outline_color = c.inverted()
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	$GameStats.add_child(lb)
	return lb

func set_game_stat(n :String, v):
	game_stat_label[n].text = "{0} : {1}".format( [n , GameStatName[n] % v ] )
