extends CharacterBody3D

@export var lookSensitivity = 0.001;

@export var groundSpeed = 25.0;
@export var groundAccel = 200.0;
@export var airMoveAccel = 15;
@export var grappleMoveAccel = airMoveAccel;
@export var jumpSpeed = 23.0;
@export var gravity = 100.0;
@export var grappleAccel = 100;

@export var maxGroundSpeed = 30.0;

var forward = Vector3(0.0, 0.0, -1.0);
var right = Vector3(1.0 ,0.0, 0.0);

enum State { IDLE, RUNNING, JUMPING, FALLING, GRAPPLING }
var state = State.FALLING;

var grapplePoint = Vector3();
var arcDistance = 0.0;
var initialForward = Vector3();

var lastVelocity = velocity;

signal can_swing;
signal cannot_swing;

signal start_grapple;
signal stop_grapple;

var hasWon = false;
signal finish;

@export var finishSphere : StaticBody3D;

var enableInput = false;

func gameStart():
	enableInput = true;
	
func gameUnpause():
	enableInput = true;

func pause():
	enableInput = false;

func restart():
	position = Vector3(0.0, 2.234, 0.0);
	rotation = Vector3(0.0, deg_to_rad(-90.0), 0.0);
	forward = Vector3(0.0, 0.0, -1.0);
	right = Vector3(1.0, 0.0, 0.0);
	up_direction = Vector3(0.0, 1.0, 0.0);
	state = State.FALLING;
	
	velocity = Vector3();
	
	var cam = $Camera3D;
	cam.rotation = Vector3(0.0, 0.0, 0.0);
	
	hasWon = false;
	
	var grapple = $Camera3D/RayCast3D/Grapple;
	grapple.grappling = false;
	
	var hook = $Camera3D/RayCast3D/Grapple/Hook;
	hook.hide();
	
func _ready():
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
	get_parent().connect("startGame", gameStart);
	get_parent().connect("unpause", gameUnpause);
	get_parent().connect("pause", pause);
	get_parent().connect("restart", restart);

func _input(event):
	if event is InputEventMouseMotion && enableInput:
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
			if Input.get_vector("move_left", "move_right", "move_backward", "move_forward") && enableInput:
				state = State.RUNNING

			if Input.is_action_pressed("jump") && enableInput:
				state = State.JUMPING;
				
			if Input.is_action_pressed("grapple") && rayCast.is_colliding() && enableInput:
				grapplePoint = rayCast.get_collision_point();
				state = State.GRAPPLING;
				start_grapple.emit();
				initialForward = forward;
				arcDistance = (grapplePoint - global_position).length();
			
			if rayCast.is_colliding():
				can_swing.emit();
			else:
				cannot_swing.emit();

			var divisor = sqrt(velocity.length()) if velocity.length() > 0.0 else 2.0;
			velocity -= velocity / divisor;

			if velocity.length() < 0.5:
				velocity = Vector3();
				
			if !is_on_floor():
				state = State.FALLING;

		State.RUNNING:
			if !Input.get_vector("move_left", "move_right", "move_backward", "move_forward") && enableInput:
				state = State.IDLE;

			if Input.is_action_pressed("grapple") && rayCast.is_colliding() && enableInput:
				grapplePoint = rayCast.get_collision_point();
				state = State.GRAPPLING;
				start_grapple.emit();
				initialForward = forward;
				arcDistance = (grapplePoint - global_position).length();

			if rayCast.is_colliding():
				can_swing.emit();
			else:
				cannot_swing.emit();

			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity += transform.basis * Vector3(input.x, 0.0, input.y) * groundAccel * dt;
			velocity.y = vy;

			if velocity.length() > maxGroundSpeed:
				velocity = velocity.normalized() * maxGroundSpeed;

			if Input.is_action_pressed("jump") && enableInput:
				state = State.JUMPING;

			if !is_on_floor():
				state = State.FALLING;

		State.JUMPING:
			velocity.y += jumpSpeed;
			state = State.FALLING;

		State.FALLING:
			if Input.is_action_pressed("grapple") && rayCast.is_colliding() && enableInput:
				grapplePoint = rayCast.get_collision_point();
				state = State.GRAPPLING;
				start_grapple.emit();
				initialForward = forward;
				arcDistance = (grapplePoint - global_position).length();
				
			if rayCast.is_colliding():
				can_swing.emit();
			else:
				cannot_swing.emit();
				
			velocity.y -= gravity * dt;

			if is_on_floor():
				state = State.IDLE;

			# In air movement
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity += transform.basis * Vector3(input.x, 0.0, input.y) * airMoveAccel * dt;
			velocity.y = vy;

		State.GRAPPLING:
			var targetPos = (grapplePoint - global_position).normalized();
			var directionOfTravel = initialForward.cross(targetPos);
				
			if (grapplePoint - finishSphere.global_position).length() < 11.0 && !hasWon:
				finish.emit();
				hasWon = true;
			
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity += transform.basis * Vector3(input.x, 0.0, input.y) * grappleMoveAccel * dt;
			velocity.y = vy;

			if rayCast.is_colliding():
				can_swing.emit();
			else:
				cannot_swing.emit();

			var velLength = velocity.length();

			velocity = directionOfTravel.normalized() * velLength;

			velocity.y -= gravity * dt;

			if Input.is_action_just_released("grapple"):
				state = State.FALLING;
				stop_grapple.emit();

	lastVelocity = velocity
	move_and_slide();
