extends Node3D
class_name Bottle

@export var bottle : MeshInstance3D
@export var cap : MeshInstance3D
var is_open : bool = false
var is_full_water : bool = true

func open(): 
	cap.hide()
	is_open = true
	
func close():
	cap.show()
	is_open = false
