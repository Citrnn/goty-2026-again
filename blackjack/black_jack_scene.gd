extends Node2D

const PLAYERS_TURN: int = 1
const DEALERS_TURN: int = 2

var currentTurn: int = 3

@onready var dealerNode: DealerNode = $"./dealerHand"
@onready var playerNode: PlayerNode  = $"./playerHand"
@onready var buttonsNode = $"./buttons"
@onready var cardScene = load("res://scenes/card_scene.tscn")
@onready var players: Array = [playerNode, dealerNode]
@onready var endScreens := $"./endingScreens"
@onready var victoryScreen := $"./endingScreens/VictoryScreen"
@onready var defeatScreen := $"./endingScreens/DefeatScreen"
@onready var drawScreen := $"./endingScreens/DrawScreen"
@onready var betNode := $"./Bet"
@onready var betSlider := $"./Bet/BetSlider"
@onready var betLabel := $"./Bet/BetLabel"
@onready var betButton := $"./Bet/BetButton"
@onready var gameNode = get_tree().get_root().get_node("./main/game")
@onready var infoYap = $"./InfoButton/InfoYap"
@onready var win_sound: AudioStreamPlayer2D = $Audio/win
@onready var lose_sound: AudioStreamPlayer2D = $Audio/lose

var betAmount:int = 0
var isGameRunning: bool = 0
signal gameEnd

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	startBet()

func _process(delta: float) -> void:
	pass



func runDealer():
	if (currentTurn == DEALERS_TURN):
		currentTurn = 3
		await dealerNode.play()
		print(dealerNode.getScore())
		currentTurn = PLAYERS_TURN
		endGame()
		await get_tree().create_timer(1.0, false).timeout
		startBet()

func hit():
	buttonsNode.hide()
	await playerNode.hit()
	print(playerNode.playerHand)
	print(playerNode.getScore())
	if playerNode.isBusted():
		await get_tree().create_timer(1.0, false).timeout
		endGame()
		startBet()
	else:
		buttonsNode.show()

func stand():
	buttonsNode.hide()
	currentTurn = DEALERS_TURN
	await runDealer()
	


func _onClickHit(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# ^ cand apesi pe butonu hit practic
		hit() # <- nebunie

func _onClickStand(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# ^ cand apesi pe butonu stand practic
		stand() # <- traznaie

func endGame():
	if (playerNode.getScore() > dealerNode.getScore() and !playerNode.isBusted()) or dealerNode.isBusted():
		print("Player won yippie")
		gameNode.money += betAmount
		makeEndScreen("victory")
		await get_tree().create_timer(1.5, false).timeout
		
	elif playerNode.getScore() < dealerNode.getScore() or playerNode.isBusted():
		print("Dealer won rigged")
		gameNode.money -= betAmount
		makeEndScreen("defeat")
		await get_tree().create_timer(1.5, false).timeout
		
	else:
		print("wow its a draw :i")
		makeEndScreen("draw")
		await get_tree().create_timer(1.5, false).timeout
	emit_signal("gameEnd")
	isGameRunning = 0

func startGame():
	isGameRunning = 1
	buttonsNode.hide()
	await playerNode.hit()
	await dealerNode.hit()
	await playerNode.hit()
	await dealerNode.hit()
	currentTurn = PLAYERS_TURN
	buttonsNode.show()

func startBet():
	dealerNode.reset()
	playerNode.reset()
	buttonsNode.hide()
	if gameNode.money > 0:
		betNode.show()
		betAmount = 0
		betSlider.max_value = gameNode.money
		betSlider.value = int(gameNode.money/2)
		betNode.show()


func _onPressBet(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		betNode.hide()
		betAmount = betSlider.value
		startGame()


func _onBetSliderSlide(value: float) -> void:
	betLabel.text = "Bet: $" + str(int(betSlider.value))

func makeEndScreen(screenType: String):
	endScreens.position = position + Vector2(0, -100)
	endScreens.modulate.a = 0
	
	if screenType == "victory": victoryScreen.show(); win_sound.play()
	elif screenType == "defeat": defeatScreen.show(); lose_sound.play()
	elif screenType == "draw": drawScreen.show(); lose_sound.play()
	
	var mover = create_tween()
	var fader = create_tween()
	
	mover.tween_property(self, "endScreens:position", Vector2(0,0), 0.5).set_ease(Tween.EASE_IN)
	fader.tween_property(self, "endScreens:modulate:a", 1, 0.5)
	await fader.finished
	await get_tree().create_timer(0.3, false).timeout
	
	var fader2 = create_tween()
	fader2.tween_property(self, "endScreens:modulate:a", 0, 0.5)
	await fader2.finished
	victoryScreen.hide(); drawScreen.hide(); defeatScreen.hide()


func _onInfoHover() -> void:
	infoYap.show()


func _onMouseUnhover() -> void:
	infoYap.hide()

func exitGame():
	if isGameRunning:
		await gameEnd 
	print("hio")
	buttonsNode.hide()
	betNode.hide()
	var fader = create_tween()
	fader.tween_property(self, "modulate:a", 0, 1.0)
	await fader.finished
	queue_free()

	
