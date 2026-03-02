extends MeshInstance3D
class_name Button3D

@export var text : String
@export var label : Label3D
enum Functionality {NUMBER, BACKSPACE, CLEAR}
@export var functionality : Functionality = Functionality.NUMBER
signal num_button_pressed(num : int)
signal backspace_button_pressed
signal clear_button_pressed
@export var color : Color #= Color.GREEN

func _ready() -> void:
	label.text = str(text)
	create_material()
	

func create_material():
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	self.material_override = material
	
func update_color():
	var material = mesh.surface_get_material(0) as StandardMaterial3D
	material.albedo_color = color

func on_press():
	match functionality:
		Functionality.NUMBER:
			num_button_pressed.emit(int(text))
		Functionality.BACKSPACE:
			backspace_button_pressed.emit()
		Functionality.CLEAR:
			clear_button_pressed.emit()
