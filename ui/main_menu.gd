extends Control
## Menu principal: JOGAR / CONTROLES / SAIR.
## JOGAR usa o sistema existente: GameState.reset() e a cena inicial (GameState.START_SCENE).

const GameState = preload("res://scripts/game_state.gd")

@onready var menu_box: Control = $Center/Box
@onready var play_button: Button = $Center/Box/PlayButton
@onready var controls_button: Button = $Center/Box/ControlsButton
@onready var quit_button: Button = $Center/Box/QuitButton
@onready var controls: Control = $ControlsScreen

var _starting := false


func _ready() -> void:
	play_button.pressed.connect(_on_play)
	controls_button.pressed.connect(_on_controls)
	quit_button.pressed.connect(_on_quit)
	controls.closed.connect(_on_controls_closed)
	play_button.grab_focus()


func _on_play() -> void:
	if _starting:
		return
	_starting = true
	GameState.reset()
	# Pequena espera para a tecla (ex.: Espaço) não "vazar" para o pulo do jogador.
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(GameState.START_SCENE)


func _on_controls() -> void:
	menu_box.visible = false
	controls.open()


func _on_controls_closed() -> void:
	menu_box.visible = true
	controls_button.grab_focus()


func _on_quit() -> void:
	get_tree().quit()
