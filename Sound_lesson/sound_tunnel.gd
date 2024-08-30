extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#checks if window/door is open
	get_node("noise_collector_area")
	var check_window = get_node("window_door_col").check_door_window_open()
	
	#hides window depending if it's "open" or not
	visible = !check_window
