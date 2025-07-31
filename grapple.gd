extends MeshInstance3D

func _process(dt):
	mesh.clear_surfaces();
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES);
	
	mesh.surface_add_vertex(get_parent().get_node("Camera3D").position);
	
	mesh.surface_add_vertex(get_parent().hitPos);
	
	mesh.surface_end();
