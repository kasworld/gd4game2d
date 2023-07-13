extends Control

signal cloud_count_changed(v :int)
signal team_count_changed(v :int)
signal ball_per_team_changed(v :int)

var vp_size :Vector2

func _on_cloud_count_value_changed(v) -> void:
	emit_signal("cloud_count_changed",v)

func _on_team_count_value_changed(v) -> void:
	emit_signal("team_count_changed",v)

func _on_ball_per_team_value_changed(v) -> void:
	emit_signal("ball_per_team_changed",v)

func init(vp :Vector2, colorteam_list :Array[ColorTeam], cloud_count :int,team_count :int, ball_per_team:int):
	vp_size = vp
	init_game_stat()
	init_teamstats(colorteam_list)

	$CloudCount.init("Cloud count", cloud_count, 0, 1000)
	$CloudCount.position.x = vp_size.x - $CloudCount.size.x
	$CloudCount.position.y = vp_size.y/2 - $CloudCount.size.y

	$TeamCount.init("Team count", team_count, 1, 100)
	$TeamCount.position.x = vp_size.x - $TeamCount.size.x
	$TeamCount.position.y = vp_size.y/2

	$BallPerTeam.init("Balls / team", ball_per_team, 1, 100)
	$BallPerTeam.position.x = vp_size.x - $BallPerTeam.size.x
	$BallPerTeam.position.y = vp_size.y/2 + $BallPerTeam.size.y

	$Help.label_settings.font_size = vp_size.y / 32


func init_teamstats(colorteam_list :Array[ColorTeam]):
	add_label_to_teamstat("Team",Color.WHITE)
	for s in ColorTeam.Stat.keys():
		add_label_to_teamstat(s.to_lower()+" ",Color.WHITE)

	for t in colorteam_list:
		t.name_label = add_label_to_teamstat(t.name.to_snake_case(), t.color)
		for c in ColorTeam.Stat.keys():
			var lb = add_label_to_teamstat(str(t.stats[c]) , t.color)
			t.labels[c] = lb

	add_label_to_teamstat("Team",Color.WHITE)
	for s in ColorTeam.Stat.keys():
		add_label_to_teamstat(s.to_lower()+" ",Color.WHITE)

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

func init_game_stat():
	for s in GameStatName.keys():
		var lb = Label.new()
		lb.label_settings = LabelSettings.new()
		lb.label_settings.font_size = vp_size.y / 30
		lb.label_settings.font_color = Color.WHITE
		lb.label_settings.outline_size = 2
		lb.label_settings.outline_color = Color.BLACK
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		game_stat_label[s] = lb
		$GameStats.add_child(lb)
		set_game_stat(s,0)

const GameStatName = {
	"GameSec" :"%04.2f",
	"FPS" :"%04.2f",
	"Ball" :"%d",
	"Shield" :"%d",
	"Bullet" :"%d",
	"Homming" :"%d",
	"Explosion" :"%d",
}
var game_stat_label :Dictionary

func set_game_stat(n :String, v):
	game_stat_label[n].text = "{0} : {1}".format( [n , GameStatName[n] % v ] )


