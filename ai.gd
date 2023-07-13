class_name AI #extends Node2D

static func connect_if_not(sg :Signal, fn :Callable):
	if not sg.is_connected(fn):
		sg.connect(fn)

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

static func rand_per_sec(delta :float, per_sec :float)->bool:
	return randf() < per_sec*delta

static func not_null_and_alive(o :Area2D)->bool:
	return o != null and o.alive

static func calc_danger_level(me :Ball, dst :Area2D)->float:
	if me.team == dst.team :
		return 0.0
	if not me.alive or not dst.alive:
		return 0.0
	var l = (dst.global_position-me.global_position).length()
#	var vl = (dst.velocity-me.velocity).length()
	return 1000.0/l

static func find_other_team_ball(ball_list :Array, t :ColorTeam)->Ball:
	if ball_list.size() == 0:
		return null
	var dst :Ball
	var try = 10
	while try > 0 :
		dst = ball_list.pick_random()
		if dst != null and dst is Ball and dst.alive and dst.team != t:
			return dst
		try -= 1
	return null

static func do_accel(delta :float, pos: Vector2, velocity :Vector2, o :Area2D)->Vector2:
	if not AI.rand_per_sec(delta, 30.0):
		return velocity
	if AI.not_null_and_alive(o):
		velocity += (pos - o.global_position).limit_length(Ball.SPEED_LIMIT)
		velocity = velocity.rotated( (randf()-0.5)*PI)
		velocity = velocity.limit_length(Ball.SPEED_LIMIT)
	return velocity

static func do_fire_bullet(from_pos :Vector2, team :ColorTeam, delta :float, o :Area2D, ball_list :Array)->Vector2:
	if not AI.rand_per_sec(delta, 5.0):
		return Vector2.ZERO
	var dst :Area2D
	if AI.not_null_and_alive(o) and not(o is HommingBullet) :
		dst = o
	else:
		var bl = find_other_team_ball(ball_list, team)
		if bl != null:
			dst = bl
	if dst == null:
		return Vector2.ZERO
	var v = AI.calc_aim_vector2(from_pos, Bullet.SPEED_LIMIT, dst.global_position, dst.velocity )
	return v

static func do_fire_homming(myteam :ColorTeam, delta :float, o :Area2D, ball_list :Array)->Area2D:
	if not AI.rand_per_sec(delta, 2.0):
		return null
	if AI.not_null_and_alive(o) and ((o is Ball) or (o is HommingBullet)):
		return o
	else:
		return find_other_team_ball(ball_list, myteam)

static func do_add_shield(delta :float)->bool:
	if not AI.rand_per_sec(delta, 2.0):
		return false
	return true

