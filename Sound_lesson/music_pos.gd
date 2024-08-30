extends Node3D

#placed outside of reverb areas layers. current layer 2

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_home"):
		
		$AudioStreamPlayer3D.play()
		
	if Input.is_action_just_pressed("ui_end"):
		
		$AudioStreamPlayer3D.stop()
	
	#example of how to manipulate sound, can add triggers instead to change effect
	if Input.is_action_just_pressed("ui_up"):
		
		get_node("AudioStreamPlayer3D").set_bus("master")
		
	if Input.is_action_just_pressed("ui_down"):
		
		get_node("AudioStreamPlayer3D").set_bus("reverb")
		
	muffle_sound()
		
		
func muffle_sound():
	
	#explained in window_door script
	var space_state = get_world_3d().direct_space_state
		
	var query = PhysicsRayQueryParameters3D.create(global_position, Global.player_current_pos)
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		
		if not result["collider"].is_in_group("player"):
			
			get_node("AudioStreamPlayer3D").set_bus("muffle")
			
			#needs a way to reset bus
			

func _on_audio_stream_player_3d_finished() -> void:
	
	#placing this audiostreamer in an area3d causes crackiling for some reason
	#it may be best to switch between buses intead of sound manipulation
	#if sound is loud by default?
	
	#this signal loops audio. trigger when sound file ends
	$AudioStreamPlayer3D.play()
