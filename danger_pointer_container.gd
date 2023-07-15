class_name DangerPointerContainer extends Node2D

#	var danger_dict = {
#		"All":[null, 0.0],
#		"Ball":[null, 0.0],
#		"Bullet":[null, 0.0],
#		"Homming":[null, 0.0],
#	}
func update_danger_dict(me :Ball, danger_dict :Dictionary):
	for k in danger_dict:
		var target = danger_dict[k][0]
		if AI.not_null_and_alive(target) == false:
			line_dict[k].visible = false
			continue
		line_dict[k].set_point_position(1, target.global_position - me.global_position)
		line_dict[k].default_color = me.team.color
		line_dict[k].visible = true

func _init() -> void:
	for k in line_dict:
		line_dict[k] = Line2D.new()
		line_dict[k].add_point( Vector2(0,0),0)
		line_dict[k].add_point( Vector2(0,0),0)
		line_dict[k].visible = false
		line_dict[k].set_width(5)
		add_child(line_dict[k])

var line_dict = {
	"All":Line2D,
	"Ball":Line2D,
	"Bullet":Line2D,
	"Homming":Line2D,
}

func toggle_visible(b :bool):
	visible = b
