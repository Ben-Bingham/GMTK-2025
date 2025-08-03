extends Label

var elapsedTime = 0.0;

var win = false;
var pause = true;

@export var player : CharacterBody3D;
@export var main : Node;

func finish():
	win = true;

func pauseFunc():
	pause = true;
	
func unpauseFunc():
	pause = false;

func restart():
	elapsedTime = 0.0;
	win = false;

func _ready():
	player.connect("finish", finish);
	main.connect("pause", pauseFunc);
	main.connect("unpause", unpauseFunc);
	main.connect("restart", restart);

func _process(dt):
	if !win && !pause:
		elapsedTime += dt;
		
		text = str(elapsedTime).pad_decimals(3);
	
	if win:
		text = ""
		var done = $Done;
		done.text = "Final Time: " + str(elapsedTime).pad_decimals(3);
		done.show();
