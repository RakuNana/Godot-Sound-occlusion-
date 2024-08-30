extends CharacterBody3D

#@onready var get_nav_map = get_parent().get_node("NavigationRegion3D")
@onready var nav_agent  = get_node("NavigationAgent3D")
#field of vision
@onready var FOV_caster = get_node("FOV_cast")

@export var speed = 100.0
#get objects instead of vectors
var all_points = []
var next_point = 0

var in_pursuit = false
var is_at_post = false
var seen_player = false
@export var neg_pos = 1
@export var is_patrolling_guard = false

#added
var player_close_by = false

#Was gonna add a jump for the lesson, ain't gonna happen
#var jump_vel = 4

func _ready():
	
	add_to_group("enemy")
	
	#FIXED! Explain! Don't use get_parent()
	
	#markers need to be at ground level to trigger, Don't know why
	for x in get_node("all_patrolling_points").get_children():
		#Vector3 y needs to be one, otherwise it will slow walk
		all_points.append(x.global_position + Vector3(0,1,0))
		
	#guard_stand_watch.append(all_points[0])
	
func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_down"):
		
			in_pursuit = false
	
	if is_patrolling_guard or in_pursuit:
		
		check_alert_state(delta)
		
	if not is_patrolling_guard and not in_pursuit:
		
		back_to_post(delta)
		
	#added
	check_for_sound()
	check_doors_and_windows()
	#needs move_and_slide() for enemy movement
	move_and_slide()
	
func get_new_target(new_target):
	
	nav_agent.set_target_position(new_target)
	
func check_alert_state(delta):
	
	if not in_pursuit:
		
		patrolling(delta)
		
	if in_pursuit:
		
		pursuit_state(delta)
	
func patrolling(delta):
	
	await get_tree().process_frame
	
	var dir_dir 
	
	nav_agent.target_position =  all_points[next_point]#.global_position
	dir_dir = nav_agent.get_next_path_position() - global_position
	
	dir_dir = dir_dir.normalized()
	
	velocity = velocity.lerp(dir_dir * speed * delta,1.0)
	
	dir_dir.y = 0
	
	look_at(global_transform.origin + dir_dir)
	
func pursuit_state(delta):
	
	#Finds enemies currt loc, and changes to new loc.
	#Translation is calc from current and next pos - These are Vector3
	var enemy_current_map_pos = global_position
	var current_target = nav_agent.get_next_path_position()
	var change_dir = (current_target - enemy_current_map_pos).normalized() 
	
	velocity = change_dir * speed * delta
	
	#add a global script for player pos
	#force enemy to look in the direction of its chase target
	look_at(Vector3(Global.player_current_pos.x,self.global_transform.origin.y ,Global.player_current_pos.z),Vector3(0,1,0))
	
	#forces enemy to look in the direction it's moving towards
	#prevents enemy from rot on the y axis
	#change_dir.y = 0
	#
	#look_at(global_transform.origin + change_dir)
	
func back_to_post(delta):
	
	#set the enemy away from start point, otherwise errors pop-up
	
	if not is_at_post:
		
		#keeps nav node from loading in before the scene, error occurs otherwise
		await get_tree().process_frame
		
		var dir_dir
		
		nav_agent.target_position = all_points[0]
		dir_dir = nav_agent.get_next_path_position() - global_position
		
		dir_dir = dir_dir.normalized()
		
		velocity = velocity.lerp(dir_dir * speed * delta,1.0)
		
		#creates a bug if not at zero
		#Players raycast allows them to climb on enemy head
		dir_dir.y = 0
		
		look_at(global_transform.origin + dir_dir)
		
		
	if is_at_post:
		
		direction_transition()
		
func direction_transition():
	
	#The point at which the current guard should be facing
		var default_rot = get_node("reset_guard_rotation/posted_guard_look_at").global_position
		
		#gets default_rot and applies the objects Basis(transform data) to var
		#Basis keeps axis coherent with each other????
		
		#will somtimes have guard face opposite dir, check marker pos for
		#negative numbers, if neg, change neg_pos to neg num
		var reset_rotation = Basis.looking_at(default_rot * neg_pos)
		#Enemies basis
		#gets the current objects rotation and stores it. pervents quaternion to rotation conversion error
		var current_rotation = basis.get_rotation_quaternion()
		
		#sets the new rotation to the object using interpolation
		#slerp is similar to lerp however, slerp takes into account angles
		basis = current_rotation.slerp(reset_rotation, 0.1)
		
		velocity = Vector3.ZERO
	
func _on_navigation_agent_3d_target_reached():
	
	if is_patrolling_guard:
		
		next_point += 1
		
		if next_point >= all_points.size():
			
			#gets last element in list
			next_point = all_points[-1]
			#resets list to element 0
			next_point = 0
			
	if not is_patrolling_guard and not in_pursuit:
		
		is_at_post = true
	
func _on_timer_timeout():
	
	check_sight()
	#Timer checks to update path finder every half-second , optimization
	get_new_target(Global.player_current_pos)
	
func check_sight():
	
	#if the FOV raycast is colliding with the player, and nothing else
	#Enemy can see player and begin to chase
	
	#Note: is_colliding uses the raycast vector length, if something
	#collides with it, the first object is used instead of it's max
	
	if seen_player:
		
		#When seen_player is true, The raycast will lock on to player pos
		FOV_caster.look_at(Global.player_current_pos,Vector3(0,1,0))
	
	if FOV_caster.is_colliding():
				
		var collider = FOV_caster.get_collider()
		
		if collider.is_in_group("player"):
			
			in_pursuit = true
			is_at_post = false
			#collider.enemy_can_see_call()
	
func _on_enemy_fov_body_entered(body):
	
	if body.is_in_group("player"):
		
		seen_player = true
	
func _on_enemy_fov_body_exited(body):
	
	if body.is_in_group("player"):
		
		seen_player = false
	
#added
func check_for_sound():
	
	#ear set to layer 9
	var sounds_heard = get_node("ear").get_overlapping_bodies()
	
	for s in sounds_heard:
		
		var player_noise = s.current_noise_level()
		
		#if player is close, adding a little bit more sound so enemy can "hear" better
		if player_close_by:
			
			player_noise += 1
			listen_for_player(player_noise)
			
		else:
			
			listen_for_player(player_noise)
	
func listen_for_player(player_noise):
	
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(self.global_position, Global.player_current_pos)
	
	var result = space_state.intersect_ray(query)
	
	#Add an alert state
	
	if not result.is_empty():
		
		#No object collision is blocking the player from the enemy
		if result["collider"].is_in_group("player"):
			
			#checks the players sound threshold,if over pursue player
			
			if player_noise >= 5:
				
				in_pursuit = true
				
	#Some object collision is blocking the player from the enemy- IE. a wall
		
		if not result["collider"].is_in_group("player"):
			
			#reduce the players noise level due to the object blocking sound
			var sound_through_wall = player_noise - 3
			
			if sound_through_wall >= 5:
				
				in_pursuit = true
	
func check_doors_and_windows():
	
	#creates intersect_rays to windows/doors/ and other openings for sound to go through
	#These openings will receive current_sound_level() and give it to the enemy if open = true
	
	#set to layer 9
	var space_state = get_world_3d().direct_space_state
	
	var find_openings = get_node("ear").get_overlapping_areas()
	
	for dw in find_openings:
		
		#finds windows and doors and connects to them
		if dw.is_in_group("sound_tunnel_area"):
			
			var query = PhysicsRayQueryParameters3D.create(self.global_position, dw.global_position)                                            
			
			var result = space_state.intersect_ray(query)
			
			if result["collider"].is_in_group("sound_tunnel"):
				
				#gets noise level from window/door
				noise_trigger_for_pursuit(result["collider"].current_noise_level())
	
func noise_trigger_for_pursuit(noise):
	
	#fixes a bug, when player walks on loud surface and enemy is near window
	#pursuit state is never triggered. 
	#found, Enemy never looks for window col. only players
	
	if noise >= 5:
	
		in_pursuit = true
	
func _on_ear_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("player"):
		
		player_close_by = true
	
func _on_ear_body_exited(body: Node3D) -> void:
	
	if body.is_in_group("player"):
		
		player_close_by = false
	
