extends Node

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit();
		if event.keycode == KEY_R:
			get_tree().reload_current_scene();
