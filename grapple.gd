extends MeshInstance3D

@export var player : CharacterBody3D;

var grappling = false;

func startGrapple():
	grappling = true;
	var hook = $Hook;
	hook.show();

func stopGrapple():
	grappling = false;
	var hook = $Hook;
	hook.hide();

func _ready():
	player.connect("start_grapple", startGrapple);
	player.connect("stop_grapple", stopGrapple);

func _process(_dt):
	mesh.clear_surfaces();

	if grappling:
		var hook = $Hook;
		var hookPoint = get_parent().get_parent().get_parent().grapplePoint;
		hook.position = to_local(hookPoint);

		mesh.surface_begin(Mesh.PRIMITIVE_LINES);

		var nudge = 0.001;
		for x in range(-3, 3):
			for z in range(-3, 3):
				mesh.surface_add_vertex(to_local(hookPoint) + Vector3(x * nudge, 0.0, z * nudge));
				mesh.surface_add_vertex(Vector3(x * nudge, 0.0, z * nudge));
	
		mesh.surface_end();
