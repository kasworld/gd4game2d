extends Area2D

var speed_limit := 50
var velocity :Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vprt = get_viewport_rect()
	position.x =  randi_range(100,vprt.size.x-100)
	position.y =  randi_range(100,vprt.size.y-100)
	$CloudSprites.frame = randi_range(0,3)
	velocity = random_vector2(speed_limit)
	if randi_range(0,1) == 0 :
		$CloudSprites.flip_h = true

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.limit_length(speed_limit)

func random_vector2(l :float) ->Vector2:
	return Vector2.ONE.rotated( randf() * 2 * PI ) * l

func line2normal(l ) -> Vector2:
	return (l.b - l.a).orthogonal().normalized()


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Wall:
		var other_shape_owner = area.shape_find_owner(area_shape_index)
		var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
		var nvt = line2normal(other_shape_node.shape)
		velocity = velocity.bounce(nvt)
