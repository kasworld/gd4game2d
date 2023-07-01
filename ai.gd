class_name AI extends Node


static func calc_aim_vector2(
	src_pos :Vector2,
	src_speed :float,
	dst_pos :Vector2, dst_vel :Vector2 )->Vector2:

	var vt = dst_pos - src_pos
	var dst_speed = dst_vel.length()
	if dst_speed == 0 :
		return vt
	var a2 = vt.angle_to(dst_vel)
	var a1 = asin(dst_speed/src_speed * sin(a2))
	var rtn = vt.rotated(a1)
	return rtn

#func accel(team :Team.Type,delta :float, velocity :Vector2)->void:
#	if randf() < 5.0*delta:
#		get_tree().current_scene.inc_team_stat(team,"accel")
#		velocity = velocity.rotated( (randf()-0.5)*PI)
