extends Node2D
@onready var yapping: Sprite2D = $UI_and_buttons/info_button/yapping
@onready var reels:= $reels

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func exitGame():
	$UI_and_buttons/play_button.disabled = true
	if reels.is_spinning:
		await reels.gameEnd
	var fader = create_tween()
	fader.tween_property(self, "modulate:a", 0, 1.0)
	await fader.finished
	queue_free()


func _on_info_button_mouse_entered() -> void:
	yapping.show()


func _on_info_button_mouse_exited() -> void:
	yapping.hide()
