extends RigidBody3D

var acceleration = 0.0;
var acceleration_max = 10.0; # TODO change to between 0 and 1

var speed = 10.0;

var mouseZeroPos = Vector2();
var resetMouse = true;

var turning = 0.0;
var turning_max = 1.0;
var maxTurnRadius = 20.0; # degrees

func _process(delta):
	if resetMouse:
		Input.warp_mouse(get_viewport().get_visible_rect().get_center());
		mouseZeroPos = get_viewport().get_visible_rect().get_center();
		resetMouse = false;
	
func _physics_process(delta):
	var carModel = $CarModel;

	apply_central_force(-carModel.global_transform.basis.z * acceleration);
	
	
	var turnAngle = turning * maxTurnRadius;
	var turnSpeed = 4.0;
	var newBasis = carModel.global_transform.basis.rotated(carModel.global_transform.basis.y, turnAngle);
	carModel.global_transform.basis = carModel.global_transform.basis.slerp(newBasis, -turnSpeed * delta);
	carModel.global_transform = carModel.global_transform.orthonormalized();
	#var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
	#car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
	#car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
	
func _input(event):
	if event is InputEventMouseMotion:
		var mousePos = event.position - mouseZeroPos;
				
		var halfHeight = get_viewport().get_visible_rect().size.y / 2.0;
		acceleration = (mousePos.y / halfHeight) * acceleration_max;
		acceleration *= -1;
		
		acceleration = clamp(acceleration, -acceleration_max, acceleration_max);
		
		var halfWidth = get_viewport().get_visible_rect().size.x / 2.0;
		turning = (mousePos.x / halfWidth) * turning_max;
		
		turning = clamp(turning, -turning_max, turning_max);
		
	if event is InputEventKey:
		if event.keycode == KEY_R:
			resetMouse = true;
