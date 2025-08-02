extends Label

var elapsedTime = 0.0;

var win = false;

@export var player : CharacterBody3D;

func finish():
	win = true;
	
func _ready():
	player.connect("finish", finish);

func _process(dt):
	if !win:
		elapsedTime += dt;
		
		text = str(elapsedTime).pad_decimals(3);
	else:
		text = ""
		var done = $Done;
		done.text = "Final Time: " + str(elapsedTime).pad_decimals(3);
		done.show();
