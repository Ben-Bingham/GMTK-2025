extends CharacterBody3D

@export var lookSensitivity = 0.001;

@export var speed = 15.0;
@export var jumpSpeed = 45.0;
@export var gravity = 10.0;

var forward = Vector3(0.0, 0.0, -1.0);
var right = Vector3(1.0 ,0.0, 0.0);

enum State { IDLE, RUNNING, FALLING, JUMPING }
var state = State.IDLE;

func _ready():
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * lookSensitivity);
		forward = forward.rotated(Vector3.UP, -event.relative.x * lookSensitivity);
				
		right = forward.cross(up_direction);
		var camera = $Camera3D;
		camera.rotate_x(-event.relative.y * lookSensitivity);
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70.0), deg_to_rad(89.9));

func _physics_process(dt):
	var motion = Vector3();
	match state:
		State.IDLE:
			if Input.is_action_pressed("move_forward"):
				state = State.RUNNING
			if Input.is_action_pressed("move_backward"):
				state = State.RUNNING
			if Input.is_action_pressed("move_left"):
				state = State.RUNNING
			if Input.is_action_pressed("move_right"):
				state = State.RUNNING
			# space -> jumping
		State.RUNNING:
			if (!Input.is_action_pressed("move_forward") && 
				!Input.is_action_pressed("move_backward") &&
				!Input.is_action_pressed("move_left") &&
				!Input.is_action_pressed("move_right")):
				state = State.IDLE;
				
			if Input.is_action_pressed("move_forward"):
				motion += forward * speed;
			if Input.is_action_pressed("move_backward"):
				motion -= forward * speed;
			if Input.is_action_pressed("move_left"):
				motion -= right * speed;
			if Input.is_action_pressed("move_right"):
				motion += right * speed;
			# Release all of WASD -> Idle
			# space -> jumping
		State.FALLING:
			# Apply Gravity
			# hit the ground -> idle
			pass
		State.JUMPING:
			# motion vector is negative in Y -> falling
			pass


	
	#if Input.is_action_pressed("jump"):
		#motion += up * dt * jumpSpeed;
#
	#motion -= up * gravity * dt;
	velocity = motion;
	print(velocity);
	move_and_slide();
