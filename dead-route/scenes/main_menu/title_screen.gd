extends Control
## TitleScreen — The first thing the player sees.
## Parallax bus background, menu fades in, melancholic music.

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var new_game_btn: Button = %NewGameButton
@onready var continue_btn: Button = %ContinueButton
@onready var settings_btn: Button = %SettingsButton
@onready var quit_btn: Button = %QuitButton
@onready var button_container: VBoxContainer = %ButtonContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	# Start title music
	AudioManager.play_music("title")
	
	# Check if save exists
	continue_btn.disabled = not _save_exists()
	
	# Connect button signals
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)
	
	# Focus sounds
	for btn in [new_game_btn, continue_btn, settings_btn, quit_btn]:
		btn.focus_entered.connect(func(): AudioManager.play_click())
	
	# Play fade-in animation if it exists
	if animation_player and animation_player.has_animation("fade_in"):
		animation_player.play("fade_in")
	
	# Grab focus on first enabled button
	new_game_btn.grab_focus()


func _on_new_game() -> void:
	AudioManager.play_confirm()
	# Transition to intro/character creation
	get_tree().change_scene_to_file("res://scenes/intro/intro_screen.tscn")


func _on_continue() -> void:
	AudioManager.play_confirm()
	# TODO: Load save and go to game screen
	print("[TitleScreen] Continue game — not yet implemented")


func _on_settings() -> void:
	AudioManager.play_confirm()
	# TODO: Settings screen
	print("[TitleScreen] Settings — not yet implemented")


func _on_quit() -> void:
	AudioManager.play_confirm()
	# Small delay so the sound plays before quitting
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _save_exists() -> bool:
	return FileAccess.file_exists("user://dead_route.db")


# Keyboard/controller navigation
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		AudioManager.play_click()
