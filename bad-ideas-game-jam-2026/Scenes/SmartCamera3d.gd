class_name SmartCamera3D
extends Camera3D

#var current: 
	#set(value):
		#print("camera_changed")
		#if value == true: 
			#became_current.emit()
		#else: 
			#lost_current.emit()

signal became_current
signal lost_current


func _set(property: StringName, value: Variant) -> bool:
	if property == "current":
		print("camera_changed")
		if value == true: 
			became_current.emit()
			print("become_current")
		else: 
			lost_current.emit()
			print("lose_curent")
		current = value
	return true
	
	
	
#@warning_ignore("native_method_override")
#func make_current():
	#super.make_current()
	#became_current.emit()
	#
#@warning_ignore("native_method_override")
#func clear_current(enable_next: bool = true):
	#super.clear_current(enable_next)
	#lost_current.emit()
