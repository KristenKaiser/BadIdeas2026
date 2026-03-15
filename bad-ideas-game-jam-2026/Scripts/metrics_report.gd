extends CanvasLayer
class_name MetricsReport

@export var missing_items_label :Label
@export var incorrect_items_label :Label
@export var shipped_items_label :Label

func close_metrics_card():
	self.hide()

func _on_continue_button_button_down() -> void:
	Global.score_manager.reset_todays_metrics()
	close_metrics_card()


func fill_metrics_card(): 
	shipped_items_label.text = "Shipped Merchandise: %s units" %Global.score_manager.todays_count_sent_items
	missing_items_label.text = "Missing Merchandise: %s units" %Global.score_manager.todays_count_missing_items
	incorrect_items_label.text = "Incorrect Merchandise Shipped: %s units" %Global.score_manager.todays_count_incorrect_items
	
	##TODO add more metrics showing metrics over time
