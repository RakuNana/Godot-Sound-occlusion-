extends Area3D


@export var ground_type : String = ""

#gets type and noise levels
var sound_emitted = {"grass" : 1,"carpet" : 1, " dirt" : 1,  
					"stone" : 2 ,"wood" : 2, 
					"puddle" : 3, "snow" : 3,
					"metal" : 6, "marble" : 6,"gravel" : 6 }

func _ready():
	pass
	#add_to_group("floors")

func get_ground_type():
	
	return ground_type
	
func send_sound():
	
	return sound_emitted[ground_type]
