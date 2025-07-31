extends CharacterBody3D

@export var lookSensitivity = 0.001;

@export var groundSpeed = 15.0;
@export var airSpeed = groundSpeed * 0.75;
@export var jumpSpeed = 30.0;
@export var gravity = 100.0;

var forward = Vector3(0.0, 0.0, -1.0);
var right = Vector3(1.0 ,0.0, 0.0);

enum State { IDLE, RUNNING, JUMPING, FALLING }
var state = State.FALLING;

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
	match state:
		State.IDLE:
			if Input.get_vector("move_left", "move_right", "move_backward", "move_forward"):
				state = State.RUNNING

			if Input.is_action_pressed("jump"):
				state = State.JUMPING;
				
			velocity = Vector3();
			
		State.RUNNING:
			if !Input.get_vector("move_left", "move_right", "move_backward", "move_forward"):
				state = State.IDLE;
				
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity = transform.basis * Vector3(input.x, 0.0, input.y) * groundSpeed;
			velocity.y = vy;

			if Input.is_action_pressed("jump"):
				state = State.JUMPING;
				
			if !is_on_floor():
				state = State.FALLING;
				
		State.JUMPING:
			velocity.y = jumpSpeed;
			state = State.FALLING;

		State.FALLING:
			velocity.y -= gravity * dt;
			
			if is_on_floor():
				state = State.IDLE;
				
			# In air movement
			var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
			var vy = velocity.y;
			velocity.y = 0;
			velocity = transform.basis * Vector3(input.x, 0.0, input.y) * airSpeed;
			velocity.y = vy;

	move_and_slide();
