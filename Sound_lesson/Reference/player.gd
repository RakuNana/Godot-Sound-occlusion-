extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sensitivity = 0.002
@onready var spring_arm = get_node("cam_pivot")

#grab sound node
@onready var get_foot_sound = get_node("audio_pos/footstep_sounds")
@onready var get_floor_id = get_node("Floor_detector" )


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#added
var has_jumped = false
#gets what floor type
var ground_snd_type = 0
#var for the name of the sound
var sound_num = 1 #needs to be set to 1 by default, sounds are num from 1 ->
#timer so footsteps don't play over each other
#can use animationplayer/tree
var footstep_timer = 0
var noise_level = 0

func _ready():
	
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	#added
	#do this in animationplayer "call_method"
	if footstep_timer >= 30:
		
		get_walk_sound(sound_num)
		footstep_timer = 0
	
	
	player_movement(delta)
	check_floor()
	move_and_slide()
	
func player_movement(delta):
	
	Global.player_current_pos = global_position
	
	if Input.is_action_just_pressed("ui_cancel"):
		#places mouse cursor to center of screen, then locks it to center
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		has_jumped = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#increase timer when player is on the move
		footstep_timer += 1
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
func _input(event):
	
	if event is InputEventMouseMotion:
		
		rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		#keeps camera from being able to 360, sprite should be parented to camera
		spring_arm.rotation.x = clamp(spring_arm.rotation.x,-PI/2, PI/2)
	
	
	
	
#added
func check_floor():
	#add to physics_process to call
	#add timer to optimze
	var areas = get_floor_id.get_overlapping_areas()
	
	#Walking SFX
	
	for x in areas:
		
		if x.is_in_group("floors") and is_on_floor():
			
			#gets SFX for footsteps
			ground_snd_type = x.get_ground_type()
			#sends sound level to enemy
			noise_level = x.send_sound()

func get_walk_sound(current_step):
	
	#will only play footstep sound if player is on the ground
	if is_on_floor():
		
		# f string that grabs the sound file
		var sound_path =  "res://sounds/player_sounds/{type}/{num}.wav"
		var get_sound = sound_path.format({"type": ground_snd_type,"num": current_step})
		get_foot_sound.stream = load(get_sound)
		get_foot_sound.play()
		
func current_noise_level():
	
	#calls down to sound emitter, and gives it the noise level
	#The enemy and window will recieve this var
	get_node("Noise_emitter").player_noise_level(noise_level)
	
	return noise_level

func _on_sound_emitter_finished():
	#randomly picks a sound file from current floor sound folder
	sound_num = randi_range(1,4)
	
