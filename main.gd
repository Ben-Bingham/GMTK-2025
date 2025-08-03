extends Node

var paused = true;
var gameStarted = false;

signal startGame;
signal unpause;
signal pause;

signal restart;

func _ready():
	var startAndResumeButton = $PauseMenu/StartAndResume;
	startAndResumeButton.text = "Start";

func pauseFunc():
	var startAndResumeButton = $PauseMenu/StartAndResume;
	startAndResumeButton.text = "Resume";
	
	var inGameUi = $InGameUI;
	inGameUi.hide();
	
	var pauseMenu = $PauseMenu;
	pauseMenu.show();
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	
	pause.emit();
	paused = true;
	
func unpauseFunc():
	if !gameStarted:
		startGame.emit();
		gameStarted = true;

	unpause.emit();
	
	var inGameUi = $InGameUI;
	inGameUi.show();
	
	var pauseMenu = $PauseMenu;
	pauseMenu.hide();
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
	paused = false;

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			if !paused:
				pauseFunc();
			
		if event.keycode == KEY_R && !paused:
			restart.emit();
			var done = $InGameUI/Stopwatch/Done;
			done.hide();
			
			var inGameUi = $InGameUI;
			inGameUi.show();
			
func _on_start_and_resume_button_down() -> void:
	unpauseFunc();
	
func _on_settings_button_down() -> void:
	pass # Replace with function body.

func _on_quit_button_down() -> void:
	get_tree().quit();
