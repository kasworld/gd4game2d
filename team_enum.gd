class_name Team extends Object

enum Type {
	NONE =-1,
	BLUE,
	GREEN,
	GREY,
	ORANGE,
	PURPLE,
	RED,
	WHITE,
	YELLOW,
	LEN,
}

static func phase(vt :Vector2)->float:
	return atan2(vt.y,vt.x)

static func calc_aim_vector2(
	src_pos :Vector2,
	src_speed :float,
	dst_pos :Vector2, dst_vel :Vector2 )->Vector2:

	var vt = dst_pos - src_pos
	var dst_speed = dst_vel.length()
	if dst_speed == 0 :
		return vt
	var a2 = phase(dst_vel) - phase(vt)
	var a1 = asin(dst_speed/src_speed * sin(a2))
	var rtn = vt.rotated(a1)
	return rtn
