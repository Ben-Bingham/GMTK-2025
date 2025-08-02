extends Label
@export var player : CharacterBody3D;

func canSwing():
	add_theme_color_override("font_color", Color(0.0, 1.0, 0.0));

func cannotSwing():
	add_theme_color_override("font_color", Color(1.0, 0.0, 0.0));

func _ready():
	player.connect("can_swing", canSwing);
	player.connect("cannot_swing", cannotSwing);
