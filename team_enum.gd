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
"""
func (vt Vector2f) Phase() float64 {
	return math.Atan2(vt[1], vt[0])
}
func (bt *Team) CalcAimAngleAndV(
	bullet gameobjtype.GameObjType, dsto *GameObj) (float64, float64) {
	s1 := gameobjtype.Attrib[bullet].SpeedLimit
	vt := dsto.PosVt.Sub(bt.Ball.PosVt)
	s2 := dsto.VelVt.Abs()
	if s2 == 0 {
		return vt.Phase(), s1
	}
	a2 := dsto.VelVt.Phase() - vt.Phase()
	a1 := math.Asin(s2 / s1 * math.Sin(a2))

	return vt.AddAngle(a1).Phase(), s1
}

"""

