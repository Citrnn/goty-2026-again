class_name MainMenuClass
extends Node2D


@onready var mainNode = get_tree().get_root().get_node("main")
@onready var gameNode : Game = $"../game"
@onready var background : TextureRect= $"./Background"
@onready var playButton:= $"./Background/PlayButton"
@onready var resetButton:=$"Background/ResetButton"
@onready var freePlayButton:=$Background/FreePlayButton

var isInAnimation: bool = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resetButton.hide()


func _process(delta: float) -> void:
	pass

func _onClickPlay(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if !isInAnimation: mainNode.unpause()
		print("test")

func showMenu():
	if !isInAnimation:
		if gameNode.gameStarted:
			resetButton.show()
		isInAnimation = 1
		background.visible = true
		var fader = create_tween()
		fader.tween_property(self, "modulate:a", 1.0, 0.2)
		var glider = create_tween()
		glider.tween_property(self, "position", Vector2(0, 0), 0.2)
		await glider.finished
		isInAnimation = 0
	
func hideMenu():
	if !isInAnimation:
		isInAnimation=1
		var fader = create_tween()
		fader.tween_property(self, "modulate:a", 0.0, 0.2)
		var glider = create_tween()
		glider.tween_property(self, "position", Vector2(-100, 0), 0.2)
		await glider.finished
		background.visible = false
		isInAnimation=0


func _onHoverPlay() -> void:
	playButton.scale = Vector2(1.3, 1.3)


func _onUnhoverPlay() -> void:
	playButton.scale = Vector2(1, 1)


func _onPressReset(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if !isInAnimation:
			mainNode.endRun("Reset")


func _onPressFreePlayButton() -> void:
	freePlayButton.hide()
	gameNode.startFreePlay()
	if !isInAnimation: mainNode.unpause()
