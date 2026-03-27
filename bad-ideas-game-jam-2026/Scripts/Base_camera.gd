extends Camera3D
class_name BaseCamera
var blur 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera_manager.cameras.append(self)
	child_ready()

func _exit_tree() -> void:
	Global.camera_manager.remove_camera(self)


func child_ready():
	pass

func add_blur():
	pass
	

	
