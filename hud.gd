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

func get_cloud_count()->int:
	return $CountContainer/CloudCount.get_value()

func get_team_count()->int:
	return $CountContainer/TeamCount.get_value()

func get_ball_per_team()->int:
	return $CountContainer/BallPerTeam.get_value()

func init(vp :Vector2, cloud_count :int,team_count :int, ball_per_team:int):
	vp_size = vp
	init_game_stat()

	$CountContainer/CloudCount.init("Cloud count", vp_size.y / 32, cloud_count, 0, 999)
	$CountContainer/TeamCount.init("Team count", vp_size.y / 32, team_count, 1, 100)
	$CountContainer/BallPerTeam.init("Balls / team", vp_size.y / 32, ball_per_team, 0, 200)
	$CountContainer/Help.label_settings.font_size = vp_size.y / 32

func enable_team_ball_input(b :bool):
	$CountContainer/TeamCount.enable(b)
	$CountContainer/BallPerTeam.enable(b)

func init_teamstats(colorteam_list :Array[ColorTeam]):
	for o in $TeamStatGrid.get_children():
		$TeamStatGrid.remove_child(o)
	$TeamStatGrid.columns = ColorTeam.Stat.keys().size() + 1

	var header_label_settings = LabelSettings.new()
	header_label_settings.outline_size = 2
	header_label_settings.font_color = Color.WHITE
	header_label_settings.outline_color = Color.BLACK
	header_label_settings.font_size = vp_size.y / 50

	add_header(header_label_settings)
	for t in colorteam_list:
		t.name_label.label_settings.font_size = vp_size.y / 50
		$TeamStatGrid.add_child(t.name_label)
		for k in t.labels:
			var lb = t.labels[k]
			lb.label_settings.font_size = vp_size.y / 50
			$TeamStatGrid.add_child(lb)
	add_header(header_label_settings)

func add_header(lbs :LabelSettings):
	add_label_to_teamstat("team",lbs)
	for s in ColorTeam.Stat.keys():
		add_label_to_teamstat(s.to_lower()+" ",lbs)

func add_label_to_teamstat(s :String, lbs :LabelSettings)->Label:
	var lb = Label.new()
	lb.text = s
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.label_settings = lbs
	$TeamStatGrid.add_child(lb)
	return lb

func init_game_stat():
	var lbset = LabelSettings.new()
	lbset.font_size = vp_size.y / 30
	lbset.font_color = Color.WHITE
	lbset.outline_size = 2
	lbset.outline_color = Color.BLACK
	for s in GameStatName.keys():
		var lb = Label.new()
		lb.label_settings = lbset
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


