extends Control


func make(teamstat :Team):
	add_label("TeamStat")
	for s in Team.StatCulumnString:
		add_label(s)

	for t in Team.TeamName:
		add_label(t)
		for c in Team.StatCulumnString:
			add_label("0")

func add_label(s :String)->void:
	var lb = Label.new()
	lb.text = s
	$GridContainer.add_child(lb)

