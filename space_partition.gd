class_name SpacePartition

var cell_w :float
var cell_h :float
var grid_x_count :int
var grid_y_count :int
var grid # [x][y][Node]

func _init(vp_size :Vector2):
	cell_w = 100
	cell_h = 100
	grid_x_count = int(vp_size.x / cell_w) + 1
	grid_y_count = int(vp_size.y / cell_h) + 1
	grid = []
	grid.resize(grid_x_count)
	for x in grid_x_count:
		grid[x] = []
		grid[x].resize(grid_y_count)
		for y in grid_y_count:
			grid[x][y] = []

func x2grid(x)->int:
	return clampi((x / cell_w), 0, grid_x_count-1)
func y2grid(y)->int:
	return clampi((y / cell_h), 0, grid_y_count-1)

func add_area2d_list(a_list : Array[Node]):
	for o in a_list:
		grid[x2grid(o.position.x)][y2grid(o.position.y)].append(o)

func find_near(p :Vector2)->Array[Node]:
	var rtn :Array[Node] = []
	var x1 = x2grid(p.x -cell_w)
	var x2 = x2grid(p.x +cell_w)
	var y1 = x2grid(p.y -cell_h)
	var y2 = x2grid(p.y +cell_h)
	for x in range(x1,x2):
		for y in range(y1,y2):
			rtn.append_array(grid[x][y])
	return rtn

