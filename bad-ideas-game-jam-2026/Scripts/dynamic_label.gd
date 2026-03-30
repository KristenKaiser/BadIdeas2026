extends Label

@export var min_font_size: int = 12
@export var max_font_size: int = 72
@export var scale_ratio: float = 0.1

func _ready():
	resized.connect(_update_font_size)
	# Defer the first call to let layout finish
	await get_tree().process_frame
	_update_font_size()

func _update_font_size():
	var label_size = size
	print("Label size: ", label_size, " | Calculated font size: ", int(minf(label_size.x, label_size.y) * scale_ratio))
	var new_size = clamp(
		int(minf(label_size.x, label_size.y) * scale_ratio),
		min_font_size,
		max_font_size
	)
	add_theme_font_size_override("font_sizes", new_size)
