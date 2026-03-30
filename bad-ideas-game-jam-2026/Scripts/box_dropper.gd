extends MeshInstance3D
class_name BoxDropper
const BOX = preload("uid://hg2wuymgg6bs")

func _ready() -> void:
	Global.box_manager.box_dropper = self
	drop_box()

func drop_box():
	var new_box : Box = BOX.instantiate()
	#new_box.set_box_size("Medium")
	
	Global.box_manager.add_box(new_box)
	new_box.global_position = global_position
	new_box.global_position.z = global_position.z + mesh.size.z/2 - new_box.box_collision_shape.shape.size.z/2
	new_box.global_position.y = global_position.y - mesh.size.y/2  + new_box.box_collision_shape.shape.size.y/2
	new_box.current_state = new_box.State.CONVEYING

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event is InputEventKey and event.pressed and event.keycode == 66:
			drop_box()
