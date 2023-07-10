extends Control


const StatCulumnString :Array[String] = [
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

var life_start := Time.get_unix_time_from_system()
var fps :float
var ball_count :int
var bullet_count :int
var shield_count :int
var homming_count :int
var effect_count :int

var vp_size :Vector2

func init_stat(vp :Vector2, colorteam_list :Array[ColorTeam]):
	vp_size = vp

	$Help.label_settings.font_size = vp_size.y / 32
	$GameInfo.label_settings.font_size = vp_size.y / 32
	add_label("TeamStat",Color.WHITE)
	for s in StatCulumnString:
		add_label(s,Color.WHITE)

	for t in colorteam_list:
		add_label(t.name, t.color)
		team_stat[t.name] = {}
		team_stat_label[t.name] = {}
		for c in StatCulumnString:
			team_stat[t.name][c] = 0
			var lb = add_label(str(team_stat[t.name][c]) , t.color)
			team_stat_label[t.name][c] = lb

func add_label(s :String, c :Color)->Label:
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

func inc_stat(team : ColorTeam, statname: String)->void:
	team_stat[team.name][statname] += 1
	team_stat_label[team.name][statname].text = str(team_stat[team.name][statname])

func _process(delta: float) -> void:
	fps = (fps+1.0/delta)/2

func _on_timer_timeout() -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	$GameInfo.text = "Run Time: %02d:%02d\nFPS: %04.2f\nBall: %d\nShield: %d\nBullet: %d\nHomming: %d\nEffect: %d" %[
		dur / 60,
		fmod(dur,60),
		fps,
		ball_count,
		shield_count,
		bullet_count,
		homming_count,
		effect_count,
		]
	fps = 0
