class_name AI

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


static func do_accel(team :Team.Type,delta :float,pos: Vector2, velocity :Vector2)->bool:
	if randf() < 5.0*delta:
		return true
	return false

static func do_fire_bullet(team :Team.Type,delta :float,pos: Vector2, velocity :Vector2)->bool:
	if randf() < 5.0*delta :
		return true
	return false

static func do_fire_homming(team :Team.Type,delta :float,pos: Vector2, velocity :Vector2)->bool:
	if randf() < 2.0*delta :
		return true
	return false

static func do_add_shield(team :Team.Type,delta :float,pos: Vector2, velocity :Vector2)->bool:
	if randf() < 2.0*delta :
		return true
	return false
