extends Node3D

@onready var player = get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#get_tree().call_group("enemy","update_target_location", player.global_transform.origin)
