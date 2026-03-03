extends MeshInstance3D
class_name Button3D

@export var text : String
@export var label : Label3D
enum Functionality {NUMBER, BACKSPACE, CLEAR, ENTER}
@export var functionality : Functionality = Functionality.NUMBER
signal num_button_pressed(num : String)
signal backspace_button_pressed
signal clear_button_pressed
signal enter_button_pressed
@export var color : Color 
@export var collision_shape : CollisionShape3D


func _ready() -> void:
	if label: 
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
			num_button_pressed.emit(text)
		Functionality.BACKSPACE:
			backspace_button_pressed.emit()
		Functionality.CLEAR:
			clear_button_pressed.emit()
		Functionality.ENTER:
			enter_button_pressed.emit()


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_press()

func size_collosion_shape():
	var material = mesh.surface_get_material(0) as StandardMaterial3D
	collision_shape.size =  material.size 
	collision_shape.position = position
