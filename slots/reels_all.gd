extends Node2D

@export var bias_mult := 0.5
@onready var reels = [$reel1, $reel2, $reel3, $reel4, $reel5]
@onready var win_sound: AudioStreamPlayer2D = $Audio/win
@onready var play_sound: AudioStreamPlayer2D = $Audio/play
@onready var spinning_sound: AudioStreamPlayer2D = $Audio/spinning
@onready var current_bet_label: Label = $"../UI_and_buttons/current_bet"
@onready var last_win_label: Label = $"../UI_and_buttons/last_win"
@onready var particle_left: CPUParticles2D = $"../UI_and_buttons/particle_left"
@onready var particle_right: CPUParticles2D = $"../UI_and_buttons/particle_right"

var is_spinning = false
var final_symbols := []
# var money :int
var current_bet :int = 10

signal gameEnd

@onready var gameNode := $"../../.."

var weights_default = {
	"7":4,
	"Crown":6,
	"clover":9,
	"bell":11,
	"grape":13,
	"melon":15,
	"lemon":24,
	"cherry":18,
	} #probability of each symbol

var multiplier_table = {
	"7":[0,0,1,5,25,500],
	"Crown":[0,0,0,4,12,70],
	"clover":[0,0,0,4,8,35],
	"bell":[0,0,0,3,6,30],
	"grape":[0,0,0,3,5,25],
	"melon":[0,0,0,2,5,20],
	"lemon":[0,0,0,2,4,20],
	"cherry":[0,0,0,1,3,15],
	}

var patterns = [
	[0,0,0,0,0],
	[1,1,1,1,1],
	[2,2,2,2,2],
	[0,1,2,1,0],
	[2,1,0,1,2],
	[0,0,1,2,2],
	[2,2,1,0,0],
	[1,0,0,0,1],
	[1,2,2,2,1],
	[0,1,1,1,0],
]

func _ready() -> void:
	randomize()
	for i in range(5):
		reels[i].index = i

func _process(delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	play()

func _on_bet_1_pressed() -> void:
	current_bet = 10
	current_bet_label.text = "Current Bet:\n" + str(current_bet)

func _on_bet_2_pressed() -> void:
	current_bet = 25
	current_bet_label.text = "Current Bet:\n" + str(current_bet)

func _on_bet_3_pressed() -> void:
	current_bet = 50
	current_bet_label.text = "Current Bet:\n" + str(current_bet)

func _on_bet_4_pressed() -> void:
	current_bet = 75
	current_bet_label.text = "Current Bet:\n" + str(current_bet)

func _on_bet_5_pressed() -> void:
	current_bet = 100
	current_bet_label.text = "Current Bet:\n" + str(current_bet)

func _on_bet_6_pressed() -> void:
	current_bet = 150
	current_bet_label.text = "Current Bet:\n" + str(current_bet)

func _on_bet_7_pressed() -> void:
	current_bet = 200
	current_bet_label.text = "Current Bet:\n" + str(current_bet)



func pick_symbol(weights:Dictionary):
	var total_weight = 0
	var sum = 0
	
	for entry in weights.values():
		total_weight += entry
	var rng = randi() % int(total_weight) + 1
	
	for i in weights.keys():
		sum +=weights[i]
		if rng <= sum:
			return i

func calc_tablou():
	var unbiased := true
	var final_symbols2 := [] #variabila asta e doar o copie sa o pot returna in play
	var weights :Dictionary
	for r in range(5):
		final_symbols2.append(["1","2","3",null])
		
	for i in range(5):
		for j in range(3):
			weights = weights_default.duplicate()
			if(unbiased == false):
				var prev_symbol = final_symbols2[i-1][j] #stanga
				weights[prev_symbol] *= (1.0 + bias_mult)
				
				prev_symbol = final_symbols2[i-1][j-1] #stanga sus
				if prev_symbol != null:
					weights[prev_symbol] *= (1.0 + bias_mult)
				
				prev_symbol = final_symbols2[i-1][j+1] #stanga jos
				if prev_symbol != null:
					weights[prev_symbol] *= (1.0 + bias_mult)
			
			final_symbols2[i][j] = pick_symbol(weights)
		unbiased = false
	return final_symbols2

func play():
	if !is_spinning and current_bet <= gameNode.money:
		is_spinning = true
		play_sound.play()
		spinning_sound.play()
		final_symbols = calc_tablou()
		var currentScore = score()
		gameNode.money -= current_bet
		for r in range(5):
			reels[r].spin(final_symbols[r])
		await reels[4].doneSpinning
		is_spinning = false
		spinning_sound.stop()
		if currentScore > 0:
			win_sound.play()
			last_win_label.text = "Last Win:\n" + str(currentScore)
			gameNode.money += currentScore
			make_particle()
		emit_signal("gameEnd")

func score():
	var first:String
	var count:int
	var sum := 0
	
	for i in range(patterns.size()):
		first = final_symbols[0][patterns[i][0]]
		count = 1
		var j := 1
		while j<5 and final_symbols[j][patterns[i][j]] == first:
			count+=1
			j+=1
		sum+= ( current_bet * multiplier_table[first][count] )
	return sum

func make_particle():
	particle_left.emitting = true
	particle_right.emitting = true
	await get_tree().create_timer(2,false).timeout
	particle_left.emitting = false
	particle_right.emitting = false
