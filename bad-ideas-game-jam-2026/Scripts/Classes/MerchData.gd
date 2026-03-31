extends Resource
class_name MerchData

@export var code : String
@export var item_name : String
@export var item: PackedScene
@export_multiline var grid_shape : String
@export var item_rotation : Vector3
@export var center_offset : Vector3
@export var trash_fill : int = 1
enum RotateAxis {X, Y, Z}
@export var rotate_axis : RotateAxis
@export var mesh_color : Color


func get_rotate_axis_string()->String:
	match rotate_axis:
		RotateAxis.X: 
			return "X"
		RotateAxis.Y:
			return "Y"
		RotateAxis.Z: 
			return "Z"
	return "X"
