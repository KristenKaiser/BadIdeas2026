extends Camera3D

func _ready() -> void:
	rotation_degrees.y = 0

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_right")and rotation_degrees.y >= 0:
		rotation_degrees.y -= 90
	elif event.is_action_pressed("ui_left") and rotation_degrees.y <= 0:
		rotation_degrees.y += 90
