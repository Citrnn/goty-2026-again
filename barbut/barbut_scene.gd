extends Node2D

@onready var betNode = $"./Bet"
@onready var betButton = $"./Bet/BetButton"
@onready var betSlider = $"./Bet/BetSlider"
@onready var betLabel = $"./Bet/BetLabel"

@onready var enemyOrigin = $"./EnemyOrigin".position
@onready var playerOrigin = $"./PlayerOrigin".position

@onready var diceScene = load("res://barbut/dice_scene.tscn")
@onready var gameNode = get_tree().get_root().get_node("./main/game")
@onready var grabberScene = load("res://barbut/dice_grabber.tscn")

@onready var endScreens := $"./EndingScreens"
@onready var victoryScreen := $"./EndingScreens/Victory"
@onready var defeatScreen := $"./EndingScreens/Lose"
@onready var drawScreen := $"./EndingScreens/Draw"
@onready var win_sound: AudioStreamPlayer2D = $Audio/win
@onready var lose_sound: AudioStreamPlayer2D = $Audio/lose

@onready var infoYap := $"./InfoButton/InfoYap"
@onready var dice_throw_sound: AudioStreamPlayer2D = $Audio/dice_throw

var bet: int

var pity:int = 0
var playerDice:Array
var enemyDice:Array

var isGameRunning:bool=false
signal gameEnd


func _ready() -> void:
	startBet()
	betSlider.value = 50


func _process(delta: float) -> void:
	pass


func startBet():
	for child in get_children():
		if child is Dice:
			child.clearDie()
		elif child is Grabber:
			child.clearGrabber()
	betNode.show()
	betSlider.max_value = gameNode.money
	#betSlider.value = int (money/2) # ts lowk a bad idea
	
	playerDice.clear()
	enemyDice.clear()

func startGame():
	isGameRunning = true
	bet = betSlider.value
	betNode.hide()
	playerDice.append(rollRiggedDice())
	playerDice.append(rollRiggedDice())
	enemyDice.append(rollDice())
	enemyDice.append(rollDice())
	
	drawEnemyDice()
	await drawPlayerDice()
	
	endGame()

func endGame():
	await get_tree().create_timer(1, false).timeout
	var playerScore:int = playerDice[0] + playerDice[1]
	var enemyScore:int = enemyDice[0] + enemyDice[1]
	if playerScore > enemyScore:
		makeEndScreen("victory")
		gameNode.money += bet
		pity = clamp(pity-1, 1, 10)
	elif playerScore < enemyScore:
		makeEndScreen("defeat")
		gameNode.money -= bet
		pity = clamp(pity+1, 1, 10)
	else:
		makeEndScreen("draw")
	if gameNode.money <= 75:
		pity = 4
	isGameRunning = false
	emit_signal("gameEnd")
	
	startBet()

func rollDice() -> int:
	return randi_range(1,6)

func rollRiggedDice() -> int:
	var bestRoll: int = 0
	for i in range(max(1, pity)):
		bestRoll = max(bestRoll, rollDice())
	return bestRoll

func drawEnemyDice():
	for i in range(2):
		var diceInstance: Dice= diceScene.instantiate()
		diceInstance.value = enemyDice[i]
		diceInstance.source = enemyOrigin
		diceInstance.target = position
		diceInstance.modulate.a = 0.6
		add_child.call_deferred(diceInstance)
		await get_tree().create_timer(0.4 * (i+1), false).timeout
		print("Enemy: " + str(enemyDice))

func drawPlayerDice():
	var grabberInstance = grabberScene.instantiate()
	grabberInstance.position = playerOrigin
	grabberInstance.dice1Value = playerDice[0]; grabberInstance.dice2Value = playerDice[1]
	add_child.call_deferred(grabberInstance)
	await grabberInstance.ended

func _onBetButtonClick(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		startGame()

func _onBetSliderChanged(value: int) -> void:
	betLabel.text = "Bet: $" + str(int(betSlider.value))



func makeEndScreen(screenType: String):
	endScreens.position = position + Vector2(0, -200)
	endScreens.modulate.a = 0
	
	if screenType == "victory": victoryScreen.show(); win_sound.play()
	elif screenType == "defeat": defeatScreen.show(); lose_sound.play()
	elif screenType == "draw": drawScreen.show(); lose_sound.play()
	
	var mover = create_tween()
	var fader = create_tween()
	
	mover.tween_property(self, "endScreens:position", Vector2(0,-100), 0.5).set_ease(Tween.EASE_IN)
	fader.tween_property(self, "endScreens:modulate:a", 1, 0.5)
	await fader.finished
	await get_tree().create_timer(0.3, false).timeout
	
	var fader2 = create_tween()
	fader2.tween_property(self, "endScreens:modulate:a", 0, 0.5)
	await fader2.finished
	victoryScreen.hide(); drawScreen.hide(); defeatScreen.hide()


func _onHoverInfo() -> void:
	infoYap.show()


func _onUnhoverInfo() -> void:
	infoYap.hide()

func exitGame():
	if isGameRunning:
		await gameEnd
	var fader = create_tween()
	fader.tween_property(self, "modulate:a", 0, 1.0)
	await fader.finished
	queue_free()
