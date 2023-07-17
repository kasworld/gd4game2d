class_name SpacePartition

var cell_w :float
var cell_h :float
var grid_x_count :int
var grid_y_count :int
var grid # [x][y][Node]

func make(vp_size :Vector2, array_node_array :Array):
	var totalobj_count :int = 0
	for ar in array_node_array:
		totalobj_count += ar.size()
	var csize = sqrt(totalobj_count)
	cell_w = vp_size.x / csize
	cell_h = vp_size.y / csize

	# make cell square
	if cell_h < cell_w:
		cell_w = cell_h
	else:
		cell_h = cell_w
	grid_x_count = int(vp_size.x / cell_w) + 1
	grid_y_count = int(vp_size.y / cell_h) + 1

#	print("%s %s (%s %s) (%s %s)" % [totalobj_count, csize, cell_w , cell_h, grid_x_count, grid_y_count])

	if grid == null:
		grid = []
	else:
		for x in grid.size():
			for y in grid[x].size():
				grid[x][y].clear()
	if grid.size() < grid_x_count:
		grid.resize(grid_x_count)
	for x in grid_x_count:
		if grid[x] == null:
			grid[x] = []
		if grid[x].size() < grid_y_count:
			grid[x].resize(grid_y_count)
		for y in grid_y_count:
			if grid[x][y] == null:
				grid[x][y] = []

	for ar in array_node_array:
		add_area2d_list(ar)


func x2grid(x)->int:
	return clampi((x / cell_w), 0, grid_x_count-1)
func y2grid(y)->int:
	return clampi((y / cell_h), 0, grid_y_count-1)

func add_area2d_list(a_list : Array[Node]):
	for o in a_list:
		grid[x2grid(o.position.x)][y2grid(o.position.y)].append(o)

func find_near(p :Vector2, r :float)->Array[Node]:
	var rtn :Array[Node] = []
	var x1 = x2grid(p.x - r)
	var x2 = x2grid(p.x + r)
	var y1 = y2grid(p.y - r)
	var y2 = y2grid(p.y + r)
	for x in range(x1,x2+1):
		for y in range(y1,y2+1):
			rtn.append_array(grid[x][y])
#	print(rtn.size())
	return rtn

