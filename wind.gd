extends AudioStreamPlayer3D

@export var player : CharacterBody3D
@export var playerScript : GDScript;

var tweeningDown = false;

func doneTweenDown():
	tweeningDown = false;

func _process(dt):
	match player.state:
		playerScript.State.FALLING:
			if !playing:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "volume_db", 100000, 1.0);
				play()
				print("Play")
			
			volume_db = player.velocity.length() / 20.0;
		_:
			#print("no fall")
			if !tweeningDown:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "volume_db", -10000, 0.5);
				tween.tween_callback(doneTweenDown);
				tweeningDown = true;
