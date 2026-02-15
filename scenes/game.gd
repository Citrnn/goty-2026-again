class_name Game
extends Node2D

@onready var label := $"./MoneyLabel"

@onready var topWindow := $"./Window"
@onready var bottomWindow := $"./BottomWindow"
@onready var door = $"Door"
@onready var door_slam_sound: AudioStreamPlayer2D  = $Door/door_slam
@onready var door_lock_sound: AudioStreamPlayer2D = $Door/door_lock
@onready var door_knock_sound: AudioStreamPlayer2D = $Door/door_knock
@onready var dialogue = load("res://scenes/Dialogue.tscn")
@onready var computer = $"./Computer"
@onready var mainNode = get_tree().get_root().get_node("main")

const LEVEL_2_THRESHOLD: int = 500
const LEVEL_3_THRESHOLD: int = 2000
const FINISH_THRESHOLD: int = 10000

var money: int = 0 : set = setMoney

var level: int = 1
const startingMoney = 100

var gameStarted:bool = 0

var time:float = 0
var botherInterval :float = 10
var isFirstBother: bool = 1
var failCount:= 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	await get_tree().create_timer(1.0, false).timeout
	if !gameStarted:
		door_knock_sound.play()
		await get_tree().create_timer(1.0, false).timeout
		await makeDialogue("Looks like someone's at the door!","Player")
		door.canInteract = 1

func startCutscene():
	await makeDialogue("Hello, tenant! \nIt's that time of the month again!", "Landlord")
	await makeDialogue("Oh no! \nBut i don't have any money!","Player")
	await makeDialogue("Not my problem, tenant! \nGive me the money or I'll kick you out","Landlord")
	door_slam_sound.play()
	door_lock_sound.play()
	await get_tree().create_timer(1.2, false).timeout
	await makeDialogue("You can't just lock me out of my own apartment","Landlord")
	await makeDialogue("Darn, I only have $100... \nThe rent is $500","Player")
	await makeDialogue("Oh, I know how to fix this! \nI can make money at my computer!","Player")
	await makeDialogue("I need to be quick though","Player")
	startGame()
	

func startGame():
	money = startingMoney
	gameStarted = 1

func startFreePlay():
	money = startingMoney
	gameStarted = 1
	level = 999

func _process(delta: float) -> void:
	if gameStarted and level < 4:
		time+=delta
	if time >= botherInterval:
		botherPlayer()
		time = 0


func botherPlayer():
	if isFirstBother:
		await makeDialogue("Luckily there are ladders next to both of your windows!", "Landlord")
		await makeDialogue("Hopefully you cant push them down", "Landlord")
		isFirstBother = 0
	else:
		match randi_range(1, 20):
			1: await makeDialogue("YOU CAN'T HIDE IN THERE FOREVER, TENANT","Landlord")
			2: await makeDialogue("LET ME IN AND GIVE ME MY MONEY!", "Landlord")
	var randomBother = randi_range(0, 1)
	if randomBother == 0:
		bottomWindow.botherPlayer(randi_range(2, 4))
	else: 
		topWindow.botherPlayer(randi_range(2, 4))
		

func setMoney(value):
	var fancyMoner :Tween = create_tween()
	fancyMoner.tween_method(Callable.create(self, "_updateLabel"), money, value, 0.5)
	money = value
	await fancyMoner.finished
	if money == 0:
		mainNode.endRun("Bankrupt")
	
	if money >= FINISH_THRESHOLD and level < 4:
		gameStarted = 0
		level = 4
		computer.updateLevel()
		topWindow.process_mode = Node.PROCESS_MODE_DISABLED
		bottomWindow.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(1.0, false).timeout
		await makeDialogue("IM RICH!!!", "Player")
		await makeDialogue("I think I still have time for one more game \nbefore the landlord breaks in!", "Player")
		await makeDialogue("But.. do I risk it all?", "Player")
		await makeDialogue("I already have more money than i've ever had...", "Player")
		await makeDialogue("Do i risk it all?", "Player", 1)
		await get_tree().create_timer(1.0, false).timeout
		level = 5
		runFinale()
	elif money >= LEVEL_3_THRESHOLD and level < 3:
		computer.updateLevel()
		await get_tree().create_timer(1.0, false).timeout
		await makeDialogue("Wow! Thats A LOT of money!", "Player")
		await makeDialogue("But... the more I have the more i can win", "Player")
		await makeDialogue("If I pay the rent now I'll be winning less!", "Player")
		await makeDialogue("But if I don't, The landlord's gonna get in eventually \nAnd kick me out for good!", "Player")
		await makeDialogue("WHAT DO I DO?!", "Player", 1)
		print("moving to level 3")
		level = 3
		
	elif money >= LEVEL_2_THRESHOLD and level < 2:
		computer.updateLevel()
		await get_tree().create_timer(1.0, false).timeout
		await makeDialogue("Wow! That was a very easy way to get the money i needed!", "Player")
		await makeDialogue("I wonder how much more I could get!", "Player")
		await makeDialogue("Hmm.. If i pay the rent now i wont have any money\nto play with...", "Player")
		await makeDialogue("What should i do?", "Player", 1)
		print("moving to level 2")
		level = 2

func _updateLabel(value):
	label.text = "$ " + str(value)
	
func makeDialogue(text: String, speaker: String, isInteractive: bool = 0):
	var dialogueInstance = dialogue.instantiate()
	dialogueInstance.text = text
	dialogueInstance.speaker = speaker
	dialogueInstance.isInteractive = isInteractive
	add_child(dialogueInstance)
	await dialogueInstance.done # it's that easy
	#await get_tree().create_timer(0.01, false).timeout


func runFinale():
	await makeDialogue("This is it... All or nothing", "Player")
	mainNode.endRun("Finale")
	
