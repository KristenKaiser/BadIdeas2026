extends Screen
class_name HealthScreen
@export var thisrt_label :Label
@export var pee_label :Label
@export var warning_screen : ColorRect
@export var pee_warning : Label
var pee_warning_threshold = 10
enum Metric {THIRST, PEE}
var warning_timer : Timer
var warning_time : int 
@export var warning_thirst_label : Label

func _ready() -> void:
	Global.health_tv = self
	Global.tv_manager.health_tv = parent_tv


func update_value(value: int, max_val : int, metric : Metric):
	match metric:
		Metric.THIRST:
			thisrt_label.text = "Thirst Level : %s / %s"%[value, max_val] 
		Metric.PEE:
			pee_label.text = "Bladder Level: %s / %s"%[value, max_val] 
			if (max_val-value) <= pee_warning_threshold * Global.healh_manager.pee_transfer_rate and warning_timer == null: 
				warning_thirst_label.text = "Thirst Level : %s / %s"%[value, max_val] 
				pee_warning.text = "00:%02d"%((max_val-value) * Global.healh_manager.pee_transfer_rate)
				warning_time = (max_val-value) * Global.healh_manager.pee_transfer_rate
				warning_screen.show()
				warning_timer = Timer.new()
				add_child(warning_timer)
				warning_timer.wait_time = 1
				warning_timer.timeout.connect(change_warning_timer)
				warning_timer.start()
			elif warning_timer != null:
				warning_timer.stop()
				warning_screen.hide()
				warning_timer.timeout.disconnect(change_warning_timer)
				
				

func change_warning_timer():
	Global.tv_manager.health_tv.warning_flash()
	warning_time -= 1
	pee_warning.text = "00:%02d"%warning_time
	if warning_time == 0:
		Global.tv_manager.health_tv.fail_light()
		warning_timer.stop()
		warning_timer.queue_free()
		warning_screen.hide()
		

	
	
