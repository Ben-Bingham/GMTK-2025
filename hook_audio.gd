extends AudioStreamPlayer3D

@export var player : CharacterBody3D

func startGrapple():
	play();

func _ready():
	player.connect("start_grapple", startGrapple);
