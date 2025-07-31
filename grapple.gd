extends MeshInstance3D

func _process(dt):
	mesh.clear_surfaces();

	mesh.surface_begin(Mesh.PRIMITIVE_LINES);

	mesh.surface_set_color(Color.RED);

	mesh.surface_add_vertex(to_local(get_parent().get_parent().get_parent().grapplePoint));
	mesh.surface_add_vertex(Vector3(0, 0, 0));
	
	mesh.surface_end();
