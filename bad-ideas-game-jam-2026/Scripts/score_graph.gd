extends ColorRect
class_name ScoreGraph

var points : Array[Vector2]
var x_gridlines : Array[Vector2]
var y_gridlines : Array[Vector2]
var highval : Vector2 = Vector2.ZERO
var lowval : Vector2 = Vector2.ONE
var y_high: int
var y_low : int

func update_graph(new_points : Array[Vector2], new_y_low : int = 0, new_y_high : int = 10 ):
	await get_tree().process_frame
	y_high = new_y_high
	y_low = new_y_low
	points = new_points.duplicate()

	set_high_and_low_value()
	#normalize points
	for point in range(points.size()): 
		points[point].x = (points[point].x-lowval.x) / (highval.x - lowval.x)
		points[point].y = (1 - points[point].y) * (y_high  - y_low) * .1
		if points[point].y == y_high:
			points[point].y -= .1
		
	
	#scale points to local space
	for point in range(points.size()): 
		if points[point].x == 1.0:
			points[point].x = .99
		points[point] *= size
	queue_redraw()

func set_high_and_low_value():
	highval = Vector2.ZERO
	lowval = points[0]
	
	for point in points: 
		if point.x > highval.x:
			highval.x = point.x
		if point.y > highval.y:
			highval.y = point.y
		
		if point.x < lowval.x:
			lowval.x = point.x
		if point.y < lowval.y:
			lowval.y = point.y

func set_gridlines():
	
	##TODO set intervals of ten to red
	x_gridlines = []
	y_gridlines = []
	var gridline_count : Vector2 = highval - lowval
	for line in range(gridline_count.x):
		x_gridlines.append(Vector2((line/gridline_count.x) * size.x, size.y))
	for line in range(y_low, y_high ):
		y_gridlines.append(Vector2(size.x, (float(line)/float(y_high)) * size.y))

func _draw() -> void:
	set_gridlines()
	for line in x_gridlines:
		draw_line(Vector2(line.x, 0), line, Color.GRAY)
	
	for line in y_gridlines:
		draw_line(Vector2(0, line.y), line, Color.GRAY)
	if points.size() >= 2:
		

		
		# draw metric line
		draw_polyline(PackedVector2Array(points), Color.BLACK, 5.0, true)


func _on_draw_graph_button_button_down() -> void:
	update_graph([Vector2(0,5), Vector2(1,3), Vector2(2,0), Vector2(3,5), Vector2(4,0)])
