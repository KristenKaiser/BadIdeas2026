extends Node3D
class_name OrderTube
@export var orgin : Node3D
@export var deposit : Node3D
@export var keypad : KeyPad
const Merchandise_script = preload("uid://8d86k6wj4m5x")
var held_object : Merchandise = null 

func _ready() -> void:
	Global.order_tube = self
	keypad.order_item.connect(order_item)

func order_item(code : String):
	var item: Merchandise = Global.merch_manager.create_from_code(code)
	held_object = item
	
	add_child(item)
	item.global_position = orgin.global_position
	item.rotation_degrees = Vector3(180, 90, 0)
	var tween = create_tween()
	tween.tween_property(held_object, "global_position", deposit.global_position, 1)
	
	
	
