extends MeshInstance3D
class_name Conveyer

@export var collision_shape : CollisionShape3D 
@export var tutorial_collision: CollisionShape3D 

func _ready() -> void:
	collision_shape.shape.size = mesh.size
	Global.conveyer = self


#func entered_conveyer(area: Area3D) -> void:
	#if area.get_parent() is Box:
		#area.get_parent().current_state = area.get_parent().State.CONVEYING
		#area.get_parent().global_position.y = global_position.y + size.y/2 + area.get_parent().box_collision_shape.shape.size.y/3


func exited_conveyer(area: Area3D) -> void:
	if area.get_parent() is Box:
		if area.get_parent().is_shipped == false: 
			area.get_parent().is_shipped = true
			Global.box_manager.ship(area.get_parent())


func _on_area_3d_area_exited(area: Area3D) -> void:
		if area.get_parent() is Box:
			if area.get_parent().is_shipped == false: 
				area.get_parent().is_shipped = true
				Global.box_manager.ship(area.get_parent())


func _on_tutorial_stop_area_entered(area: Area3D) -> void:
	if area.name == "box_collision":
		var box : Box = area.get_parent()
		if box.is_tutorial:
			(func ():tutorial_collision.disabled = true).call_deferred()
			if Global.tutorial_manager.tutorial_status[TutorialManager.Tutorials.ALONE] == false:
				box.current_state = Box.State.STILL
				# play tutorial
				if Global.tutorial_manager.tutorial_status[TutorialManager.Tutorials.PLACE] == false:
					Global.tutorial_manager.display_overseer_text(Global.tutorial_manager.place, TutorialManager.Tutorials.PLACE)
			
			
