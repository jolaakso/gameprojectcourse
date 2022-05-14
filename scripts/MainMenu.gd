extends Control

var quit_confirmation_scene = load("res://QuitConfirmation.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if GameSave.saved_game_present():
		get_node("ButtonsContainer/LoadButton").visible = true

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()

func _on_QuitButton_pressed():
	var quit_confirmation = get_node_or_null("QuitConfirmation")
	quit_confirmation.visible = true

func _on_QuitConfirmation_confirmed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _on_StartButton_pressed():
	GameSave.delete_save()
	RegionLoader.delete_db()
	return get_tree().change_scene("res://World.tscn")

func _on_LoadButton_pressed():
	GameSave.load_save()
	return get_tree().change_scene("res://World.tscn")


func _on_CreditsButton_pressed():
	get_node("ButtonsContainer").visible = false
	get_node("Credits").visible = true


func _on_BackButton_pressed():
	get_node("ButtonsContainer").visible = true
	get_node("Credits").visible = false
