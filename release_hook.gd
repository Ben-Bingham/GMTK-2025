extends AudioStreamPlayer3D

@export var player : CharacterBody3D

func endGrapple():
	play();

func _ready():
	player.connect("stop_grapple", endGrapple);
