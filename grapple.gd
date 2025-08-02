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
		hook.position = to_local(get_parent().get_parent().get_parent().grapplePoint);
		mesh.surface_begin(Mesh.PRIMITIVE_LINES);

		mesh.surface_set_color(Color.RED);

		mesh.surface_add_vertex(to_local(get_parent().get_parent().get_parent().grapplePoint));
		mesh.surface_add_vertex(Vector3(0, 0, 0));
		
		mesh.surface_end();
