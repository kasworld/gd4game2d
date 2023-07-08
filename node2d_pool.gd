class_name Node2DPool

var pool := []
var instantiatefn : Callable

func _init(newfn :Callable) -> void:
	instantiatefn = newfn

func get_node2d()->Node2D:
	if pool.size() > 0 :
		return pool.pop_back()
	return instantiatefn.call()

func put_node2d( o :Node2D):
	pool.push_back(o)
