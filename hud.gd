extends Control

const TeamName :Array[String] = [
	"BLUE",
	"GREEN",
	"GREY",
	"ORANGE",
	"PURPLE",
	"RED",
	"WHITE",
	"YELLOW",
]

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
var fps :int
var ball_count :int
var bullet_count :int
var shield_count :int
var homming_count :int

func init_stat():
	add_label("TeamStat")
	for s in StatCulumnString:
		add_label(s)

	for t in TeamName:
		add_label(t)
		team_stat[t] = {}
		team_stat_label[t] = {}
		for c in StatCulumnString:
			team_stat[t][c] = 0
			var lb = add_label(str(team_stat[t][c]))
			team_stat_label[t][c] = lb

func add_label(s :String)->Label:
	var lb = Label.new()
	lb.text = s
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$TeamStatGrid.add_child(lb)
	return lb

func inc_stat(team : Team.Type, statname: String)->void:
	var teamname = TeamName[team]
	team_stat[teamname][statname] += 1
	team_stat_label[teamname][statname].text = str(team_stat[teamname][statname])


func _process(_delta: float) -> void:
	fps += 1

func _on_timer_timeout() -> void:
	var dur = Time.get_unix_time_from_system() - life_start
	$GameInfo.text = "Run Time: %02d:%02d\nFPS: %02d\nBall: %d\nShield: %d\nBullet: %d\nHomming: %d" %[
		dur / 60,
		fmod(dur,60),
		fps,
		ball_count,
		shield_count,
		bullet_count,
		homming_count,
		]
	fps = 0
