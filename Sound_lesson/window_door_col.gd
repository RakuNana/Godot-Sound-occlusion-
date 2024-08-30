extends StaticBody3D


var player_in_room := false
var is_opened := false
var received_sound := 0
var get_data = null
var query = null

#This script will run when player is in a room(area3d) w/open door/win.
#The sound with the highest value will be taken. whether it be the enemy2player
#or enemy2dor/win2player

#using a collider object because, intersect_rays can't collide with area3d
#raycast can be used also but, created bugs when colliding with walls
#put this collision on another layer so player and other enities can pass through it

func _ready() -> void:
	
	print(is_opened)

func _process(_delta):
	
	#added to group sound_tunnel, enemy will look for this group
	#during collision
	
	check_player_sound()
	open_door_window()
	
func check_door_window_open():
	
	return is_opened
	
func open_door_window():
	
	if Input.is_action_just_pressed("ui_left"):
		
		#called from the parent node now, no longer depended on node tree setup
		is_opened = not is_opened
	
func current_noise_level():
	
	return received_sound

func check_player_sound():
	
	#If player enters sound rails area3d. They are in the room, raycast will get noise level
	if player_in_room and is_opened:
		
		#needs to reduce sound when closed, not ignore sound. currently ignores
		var space_state = get_world_3d().direct_space_state
		
		query = PhysicsRayQueryParameters3D.create(get_parent().global_position, Global.player_current_pos)
		
		var result = space_state.intersect_ray(query)
		
		if not result.is_empty():
			
			if result["collider"].is_in_group("player"):
				
				received_sound = result["collider"].current_noise_level()
				
				
			
#called from noise_collector_area
func _on_noise_collector_area_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("player"):
		
		player_in_room = true


func _on_noise_collector_area_body_exited(body: Node3D) -> void:
	
	
	if body.is_in_group("player"):
		print("bye")
		player_in_room = false
