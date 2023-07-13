class_name Node2DPool

var pool :Array[Node2D] = []
var instantiatefn : Callable
var get_count :int
var put_count :int
var reuse_count :int
var make_count :int

func _init(newfn :Callable) -> void:
	instantiatefn = newfn

func get_node2d()->Node2D:
	get_count +=1
	if pool.size() > 0 :
		reuse_count +=1
		return pool.pop_back()
	make_count +=1
	return instantiatefn.call()

func put_node2d(o :Node2D)->Node2D:
	put_count +=1
	pool.push_back(o)
	return o
