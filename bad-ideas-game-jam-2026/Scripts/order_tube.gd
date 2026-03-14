extends CSGCylinder3D
class_name OrderTube
@export var deposit : Node3D
@export var keypad : KeyPad
const Merchandise_script = preload("uid://8d86k6wj4m5x")

func _ready() -> void:
	keypad.order_item.connect(order_item)

func order_item(code : String):
	var item: Merchandise = Global.merch_manager.create_from_code(code)
	deposit.add_child(item)
	item.rotation_degrees = Vector3(180, 90, 0)
	
	#var new_item : Node3D = item.instantiate()
	#new_item.set_script(Merchandise_script)
	#deposit.add_child(new_item)
	#new_item.position = deposit.position
