extends CharacterBody3D

@export var lookSensitivity = 0.001;

@export var groundSpeed = 25.0;
@export var airSpeed = groundSpeed * 1.0;
@export var grappleAirSpeed = groundSpeed * 1;
@export var jumpSpeed = 23.0;
@export var gravity = 100.0;
@export var grappleSpeed = 50.0;
var forward = Vector3(0.0, 0.0, -1.0);
var right = Vector3(1.0 ,0.0, 0.0);

enum State { IDLE, RUNNING, JUMPING, FALLING, GRAPPLING }
var state = State.FALLING;
var lastState = state;

var grapplePoint = Vector3();

func _ready():
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * lookSensitivity);
		forward = forward.rotated(Vector3.UP, -event.relative.x * lookSensitivity);
				
		right = forward.cross(up_direction);
		var camera = $Camera3D;
		camera.rotate_x(-event.relative.y * lookSensitivity);
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.9), deg_to_rad(89.9));

func _physics_process(dt):
	var rayCast = $Camera3D/RayCast3D;
	
	match state:
		State.IDLE:
			print("DILE")
			if Input.get_vector("move_left", "move_right", "move_backward", "move_forward"):
				state = State.RUNNING

			if Input.is_action_pressed("jump"):
				state = State.JUMPING;
				
			if Input.is_action_pressed("grapple") && rayCast.is_colliding():
				grapplePoint = rayCast.get_collision_point();
				state = State.GRAPPLING;

			velocity = Vector3();
			
		State.RUNNING:
			if !Input.get_vector("move_left", "move_right", "move_backward", "move_forward"):
				state = State.IDLE;
			if Input.is_action_pressed("grapple") && rayCast.is_colliding():
				grapplePoint = rayCast.get_collision_point();
				state = State.GRAPPLING;
				
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			apply_force(input * 2.0);
			#var vy = velocity.y;
			#velocity.y = 0;
			#velocity = transform.basis * Vector3(input.x, 0.0, input.y) * groundSpeed;
			#velocity.y = vy;

			if Input.is_action_pressed("jump"):
				state = State.JUMPING;
				
			if !is_on_floor():
				state = State.FALLING;
				
		State.JUMPING:
			velocity.y = jumpSpeed;
			state = State.FALLING;

		State.FALLING:
			if Input.is_action_pressed("grapple") && rayCast.is_colliding():
				grapplePoint = rayCast.get_collision_point();
				state = State.GRAPPLING;
				
			velocity.y -= gravity * dt;
			
			if is_on_floor():
				state = State.IDLE;
				
			# In air movement
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity = transform.basis * Vector3(input.x, 0.0, input.y) * airSpeed;
			velocity.y = vy;
		
		State.GRAPPLING:
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity += transform.basis * Vector3(input.x, 0.0, input.y) * grappleAirSpeed * dt;
			velocity.y = vy;
			
			var directionToGrapple = grapplePoint - global_position;
			velocity += directionToGrapple.normalized() * dt * grappleSpeed;

			if Input.is_action_just_released("grapple"):
				state = State.FALLING;
				

				
	move_and_slide();


#extends CharacterBody3D
#
#@export var lookSensitivity = 0.001;
#
#@export var groundSpeed = 25.0;
#@export var airSpeed = groundSpeed * 1.0;
#@export var grappleAirSpeed = groundSpeed * 1;
#@export var jumpSpeed = 23.0;
#@export var gravity = 100.0;
#@export var grappleSpeed = 50.0;
#var forward = Vector3(0.0, 0.0, -1.0);
#var right = Vector3(1.0 ,0.0, 0.0);
#
#enum State { IDLE, RUNNING, JUMPING, FALLING, GRAPPLING }
#var state = State.FALLING;
#var lastState = state;
#
#var grapplePoint = Vector3();
#
#func _ready():
	#motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
#
#func _input(event):
	#if event is InputEventMouseMotion:
		#rotate_y(-event.relative.x * lookSensitivity);
		#forward = forward.rotated(Vector3.UP, -event.relative.x * lookSensitivity);
				#
		#right = forward.cross(up_direction);
		#var camera = $Camera3D;
		#camera.rotate_x(-event.relative.y * lookSensitivity);
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.9), deg_to_rad(89.9));
#
#func _physics_process(dt):
	#var rayCast = $Camera3D/RayCast3D;
	#
	#match state:
		#State.IDLE:
			#print("DILE")
			#if Input.get_vector("move_left", "move_right", "move_backward", "move_forward"):
				#state = State.RUNNING
#
			#if Input.is_action_pressed("jump"):
				#state = State.JUMPING;
				#
			#if Input.is_action_pressed("grapple") && rayCast.is_colliding():
				#grapplePoint = rayCast.get_collision_point();
				#state = State.GRAPPLING;
#
			#velocity = Vector3();
			#
		#State.RUNNING:
			#if !Input.get_vector("move_left", "move_right", "move_backward", "move_forward"):
				#state = State.IDLE;
			#if Input.is_action_pressed("grapple") && rayCast.is_colliding():
				#grapplePoint = rayCast.get_collision_point();
				#state = State.GRAPPLING;
				#
			#var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			#var vy = velocity.y;
			#velocity.y = 0;
			#velocity = transform.basis * Vector3(input.x, 0.0, input.y) * groundSpeed;
			#velocity.y = vy;
#
			#if Input.is_action_pressed("jump"):
				#state = State.JUMPING;
				#
			#if !is_on_floor():
				#state = State.FALLING;
				#
		#State.JUMPING:
			#velocity.y = jumpSpeed;
			#state = State.FALLING;
#
		#State.FALLING:
			#if Input.is_action_pressed("grapple") && rayCast.is_colliding():
				#grapplePoint = rayCast.get_collision_point();
				#state = State.GRAPPLING;
				#
			#velocity.y -= gravity * dt;
			#
			#if is_on_floor():
				#state = State.IDLE;
				#
			## In air movement
			#var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			#var vy = velocity.y;
			#velocity.y = 0;
			#velocity = transform.basis * Vector3(input.x, 0.0, input.y) * airSpeed;
			#velocity.y = vy;
		#
		#State.GRAPPLING:
			#var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			#var vy = velocity.y;
			#velocity.y = 0;
			#velocity += transform.basis * Vector3(input.x, 0.0, input.y) * grappleAirSpeed * dt;
			#velocity.y = vy;
			#
			#var directionToGrapple = grapplePoint - global_position;
			#velocity += directionToGrapple.normalized() * dt * grappleSpeed;
#
			#if Input.is_action_just_released("grapple"):
				#state = State.FALLING;
				#
#
				#
	#move_and_slide();
