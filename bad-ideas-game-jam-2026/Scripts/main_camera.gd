extends BaseCamera

enum Direction {LEFT, CENTER, RIGHT}
var current_direction : Direction 

var x_max_rotation_change : float = 35
var y_max_rotation_change : float = 40

var left_position = Vector3(-.885, 1.75, -1.5)
var left_rotation = Vector3(-15, 101.5, 0)

#var center_position = Vector3(-.3, 1.75, -2.02)
#var center_rotation = Vector3(-45, 0, 0)

var center_position = Vector3(-.3, 1.75, -2.02)
var center_rotation = Vector3(-57 + x_max_rotation_change, 5, 0)

var right_position = Vector3(0, 1.75, -1.5)
var right_rotation = Vector3(-15, -101.5, 0)

func child_ready() -> void:
	move_camera(Direction.CENTER)

func _process(delta: float) -> void:
	if current_direction == Direction.CENTER:
		Global.camera_manager.follow_mouse(self, center_rotation, x_max_rotation_change, y_max_rotation_change, delta, 100.0, Vector2(.75,.75))

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_right"):
		if current_direction == Direction.LEFT:
			move_camera(Direction.CENTER)
		elif current_direction == Direction.CENTER: 
			move_camera(Direction.RIGHT)
	elif event.is_action_pressed("ui_left"):
		if current_direction == Direction.RIGHT:
			move_camera(Direction.CENTER)
		elif current_direction == Direction.CENTER: 
			move_camera(Direction.LEFT)

func move_camera(direction : Direction): 
	if Global.camera_manager.is_locked:
		return
	current_direction = direction
	match direction:
		Direction.RIGHT:
			position = right_position
			rotation_degrees = right_rotation
			#fov = 75
		Direction.CENTER:
			position = center_position
			rotation_degrees = center_rotation
			#fov = 100
		Direction.LEFT:
			position = left_position
			rotation_degrees = left_rotation
			#fov = 75
		
