extends Node3D
class_name Box

enum State {ENTERING, CONVEYING, EXITING}
var current_state : State

	
func _process(delta: float) -> void:
	match current_state:
		State.ENTERING:
			entering(delta)
		State.CONVEYING:
			conveying(delta)
		State.EXITING: 
			exiting(delta)

func entering(delta: float):
	position.y -= Global.box_drop_speed * delta
	
func conveying(delta: float): 
	position.x += Global.conveyer_speed *delta

func exiting(delta: float):
	position.y -= Global.box_drop_speed * delta

func ship():
	Global.box_manager.box_dropper.drop_box()
	await get_tree().create_timer(1).timeout
	self.queue_free()

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				Global.merch_manager.place_held_merch(self, Vector3.ZERO)
