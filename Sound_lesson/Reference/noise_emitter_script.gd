extends Area3D

#set this area3Ds collision layer to 9, so enemy ear and sound tunnels noise_collector area can recieve sound from player
#Needed for intersect raycast in enemys listen_for_player func. Its looking for an area

func player_noise_level(noise_level):
	
	#called in players main script, noise level is 
	#grabbed from there and sent here. Returns it to enemy and windows/doors
	
	return noise_level
