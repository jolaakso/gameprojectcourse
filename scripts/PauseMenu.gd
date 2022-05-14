extends Control

signal back_to_main
signal game_saved

func _input(event):
	if event.is_action_pressed("pause_menu"):
		toggle_pause()

func _on_BackToMainButton_pressed():
	# no need to display this menu or pause anymore
	toggle_pause()
	return get_tree().change_scene("res://MainMenu.tscn")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()

func _on_QuitConfirmation_confirmed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _on_ExitGame_pressed():
	var quit_confirmation = get_node("QuitConfirmation")
	quit_confirmation.visible = true

func _on_ContinueButton_pressed():
	toggle_pause()

func toggle_pause():
	if !get_node("PauseMenuMain").visible:
		return
	var was_paused = get_tree().paused
	if was_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = !was_paused
	visible = !was_paused

func _on_SaveGameButton_pressed():
	emit_signal("game_saved")

func confirm_game_saved():
	get_node("PauseMenuMain").visible = false
	get_node("GameSaveMenu").visible = true

func ack_game_saved():
	get_node("GameSaveMenu").visible = false
	get_node("PauseMenuMain").visible = true

func _on_OKButton_pressed():
	ack_game_saved()
