extends Node3D
class_name LabelPrinter


const SHIPPING_LABEL = preload("uid://yxmuymbdq6df")


@export var printer : MeshInstance3D
@export var button : Button3D

func _ready() -> void:
	button.enter_button_pressed.connect(get_label)

func get_label(): 
	for child in get_children():
		if child is ShippingLabel:
			return
	if Global.camera_manager.held_object is ShippingLabel:
		return
	var shipping_label :ShippingLabel = SHIPPING_LABEL.instantiate()
	add_child(shipping_label)
	shipping_label.position.x += printer.mesh.size.x/2
	shipping_label.position.y += (printer.mesh.size.x/4) 
	shipping_label.resize_mesh_to_label()
