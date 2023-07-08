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

const Name :Array[String] = [
	"BLUE",
	"GREEN",
	"BLACK",
	"ORANGE",
	"PURPLE",
	"RED",
	"WHITE",
	"YELLOW",
]

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

enum GameObjectType {
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
