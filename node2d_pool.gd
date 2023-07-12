class_name Node2DPool

var pool := []
var instantiatefn : Callable
var total_count :int
var reuse_count :int
var make_count :int

func _init(newfn :Callable) -> void:
	instantiatefn = newfn

func get_node2d()->Node2D:
	total_count +=1
	if pool.size() > 0 :
		reuse_count +=1
		return pool.pop_back()
	make_count +=1
	return instantiatefn.call()

func put_node2d( o :Node2D):
	pool.push_back(o)
