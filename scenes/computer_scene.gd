extends Node2D

@onready var blackjack = load("res://blackjack/black_jack_scene.tscn")
@onready var dice = load("res://barbut/barbut_scene.tscn")
@onready var slots = load("res://slots/slots_scene.tscn")
@onready var gameNode = $".."

@onready var playerNode = $"../../Player"

@onready var buttonsNode = $"./Buttons"
@onready var barbutButton = $"./Buttons/BarbutButton"
@onready var blackjackButton = $"./Buttons/BlackjackButton"
@onready var slotsButton = $"./Buttons/SlotsButton"


var activeGame

func _ready() -> void:
	updateLevel()
	#slotsButton.modulate.a = 0.3
	#blackjackButton.modulate.a = 0.3
	#barbutButton.modulate.a = 1

func _process(delta: float) -> void:
	pass


func updateLevel():
	buttonsNode.show()
	if activeGame:
		await activeGame.exitGame()
	slotsButton.modulate.a = 0.3
	blackjackButton.modulate.a = 0.3
	barbutButton.modulate.a = 0.3
	match gameNode.level:
		1: barbutButton.modulate.a = 1
		2: blackjackButton.modulate.a = 1
		3: slotsButton.modulate.a = 1
		999: barbutButton.modulate.a = 1; blackjackButton.modulate.a = 1; slotsButton.modulate.a = 1
		# free play ^

func _onPressBarbutButton(event: InputEvent) -> void:
	if (gameNode.level == 1 or gameNode.level == 999) and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var barbutInstance = dice.instantiate()
		add_child.call_deferred(barbutInstance)
		activeGame = barbutInstance
		buttonsNode.hide()


func _onClickBlackjack(event: InputEvent) -> void:
	if (gameNode.level == 2 or gameNode.level == 999) and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var blackjackInstance = blackjack.instantiate()
		add_child.call_deferred(blackjackInstance)
		activeGame = blackjackInstance
		buttonsNode.hide()


func _onClickSlots(event: InputEvent) -> void:
	if (gameNode.level == 3 or gameNode.level == 999) and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var slotsInstance = slots.instantiate()
		add_child.call_deferred(slotsInstance)
		activeGame = slotsInstance
		buttonsNode.hide()


func _onMouseEnteredBarbut() -> void:
	if (gameNode.level == 1 or gameNode.level == 999):
		barbutButton.scale = Vector2(1.5, 1.5)


func _onMouseExitBarbut() -> void:
	barbutButton.scale = Vector2(1, 1)


func _onHoverBlackjack() -> void:
	if (gameNode.level == 2 or gameNode.level == 999):
		blackjackButton.scale = Vector2(1.5, 1.5)


func _onUnhoverBlackjack() -> void:
	blackjackButton.scale = Vector2(1, 1)


func _onMouseHover() -> void:
	if (gameNode.level == 3 or gameNode.level == 999):
		slotsButton.scale = Vector2(1.5, 1.5)


func _onMouseUnhover() -> void:
	slotsButton.scale = Vector2(1, 1)
