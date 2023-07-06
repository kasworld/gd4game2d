class_name AI extends Node2D

func calc_aim_vector2(
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

func rand_per_sec(delta :float, per_sec :float)->bool:
	return randf() < per_sec*delta

func do_accel(_team :Team.Type,delta :float,_pos: Vector2, velocity :Vector2, o :Area2D)->Vector2:
	if not rand_per_sec(delta, 30.0):
		return velocity
	if not_null_and_alive(o):
		velocity += (position - o.global_position).limit_length(Ball.SPEED_LIMIT)
		velocity = velocity.rotated( (randf()-0.5)*PI)
		velocity = velocity.limit_length(Ball.SPEED_LIMIT)
	return velocity

func not_null_and_alive(o :Area2D)->bool:
	return o != null and o.alive

func find_other_team_ball(team :Team.Type) ->Ball:
	var bl = get_tree().current_scene.find_other_team_ball(team)
	if not not_null_and_alive(bl) or bl.team == team:
		return null
	return bl

func do_fire_bullet(from_pos :Vector2, team :Team.Type,delta :float,o :Area2D)->Vector2:
	if not rand_per_sec(delta, 5.0):
		return Vector2.ZERO
	var dst :Area2D
	if not_null_and_alive(o) and not(o is HommingBullet) :
		dst = o
	else:
		var bl = find_other_team_ball(team)
		if bl != null:
			dst = bl
	if dst == null:
		return Vector2.ZERO
	var v = calc_aim_vector2(from_pos, Bullet.SPEED_LIMIT, dst.global_position, dst.velocity )
	return v

func do_fire_homming(team :Team.Type,delta :float,o :Area2D)->Area2D:
	if not rand_per_sec(delta, 2.0):
		return null
	if not_null_and_alive(o) and ((o is Ball) or (o is HommingBullet)):
		return o
	else:
		return find_other_team_ball(team)

func do_add_shield(_team :Team.Type,delta :float,_pos: Vector2, _velocity :Vector2)->bool:
	if not rand_per_sec(delta, 2.0):
		return false
	return true

func calc_danger_level(me :Ball, dst :Area2D)->float:
	if me.team == dst.team :
		return 0.0
	if not me.alive or not dst.alive:
		return 0.0
	var l = (dst.global_position-me.global_position).length()
#	var vl = (dst.velocity-me.velocity).length()
	return 1000.0/l
