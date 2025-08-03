extends AudioStreamPlayer3D

@export var player : CharacterBody3D

func finish():
	play();

func _ready():
	player.connect("finish", finish);
