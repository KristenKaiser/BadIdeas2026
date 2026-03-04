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
	self.queue_free()
	
