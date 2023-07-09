class_name Team

enum Type {
	NONE =-1,
	BLUE,
	GREEN,
	BLACK,
	ORANGE,
	PURPLE,
	RED,
	WHITE,
	YELLOW,
	LEN,
}

static func Name(t :Type) ->String:
	return Type.keys()[t+1]

const TeamColor = {
	Type.BLUE : Color.BLUE,
	Type.GREEN : Color.GREEN,
	Type.BLACK : Color.BLACK,
	Type.ORANGE : Color.ORANGE,
	Type.PURPLE : Color.PURPLE,
	Type.RED : Color.RED,
	Type.WHITE : Color.WHITE,
	Type.YELLOW : Color.YELLOW,
}

enum ObjectType {
	BallSpawn,
	Ball,
	BallExplode,
	Shield,
	ShieldExplode,
	Bullet,
	BulletExplode,
	HommingBullet,
	HommingExplode,
	Cloud,
}
