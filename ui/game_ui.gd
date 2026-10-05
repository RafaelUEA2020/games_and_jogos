extends Node
## UI global (autoload "GameUI"): HUD de corações + menu de pausa.
## NÃO altera o gameplay: só LÊ GameState.player_hp e usa get_tree().paused.
##  - HUD: aparece só quando existe um Player na cena (some no menu principal).
##  - Pausa: ESC (ação embutida "ui_cancel") durante o gameplay.

const GameState = preload("res://scripts/game_state.gd")
const MENU_SCENE := "res://ui/main_menu.tscn"

@onready var hud: CanvasLayer = $HudLayer
@onready var hearts: HBoxContainer = $HudLayer/Hearts
@onready var pause_layer: CanvasLayer = $PauseLayer
@onready var pause_menu: Control = $PauseLayer/PauseMenu
@onready var resume_button: Button = $PauseLayer/PauseMenu/Center/Box/ResumeButton
@onready var controls_button: Button = $PauseLayer/PauseMenu/Center/Box/ControlsButton
@onready var menu_button: Button = $PauseLayer/PauseMenu/Center/Box/MenuButton
@onready var controls: Control = $PauseLayer/ControlsScreen

var _resuming := false
var _shown_hp := -999


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # continua funcionando com o jogo pausado
	pause_layer.visible = false
	resume_button.pressed.connect(_resume)
	controls_button.pressed.connect(_open_controls)
	menu_button.pressed.connect(_to_menu)
	controls.closed.connect(_on_controls_closed)


func _player() -> Node:
	return get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	var player := _player()
	hud.visible = player != null
	if player == null:
		return
	# Esconde o texto antigo "HP: N" (só a parte visual; o HP em si não é tocado).
	var old_label = player.get("hp_label")
	if old_label != null and old_label.visible:
		old_label.visible = false
	# Corações = HP real do jogo.
	var hp := clampi(GameState.player_hp, 0, hearts.get_child_count())
	if hp != _shown_hp:
		_shown_hp = hp
		for i in hearts.get_child_count():
			hearts.get_child(i).visible = i < hp


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or _resuming:
		return
	if controls.visible:
		return   # a própria tela de controles trata o ESC
	if get_tree().paused and pause_layer.visible:
		get_viewport().set_input_as_handled()
		_resume()
		return
	var player := _player()
	# Não pausa durante a sequência de morte (o timer de morte do gameplay não respeita pausa).
	if player != null and not get_tree().paused and not player.get("dead"):
		get_viewport().set_input_as_handled()
		_open_pause()


func _open_pause() -> void:
	get_tree().paused = true
	controls.visible = false
	pause_menu.visible = true
	pause_layer.visible = true
	resume_button.grab_focus()


func _resume() -> void:
	if _resuming:
		return
	_resuming = true
	pause_layer.visible = false
	# Espera alguns ticks de física antes de despausar: a tecla usada (ESC/Espaço/Enter)
	# não pode "vazar" como ação do jogador (ex.: pulo) no primeiro frame.
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false
	_resuming = false


func _open_controls() -> void:
	pause_menu.visible = false
	controls.open()


func _on_controls_closed() -> void:
	pause_menu.visible = true
	controls_button.grab_focus()


func _to_menu() -> void:
	pause_layer.visible = false
	get_tree().paused = false
	GameState.reset()   # sistema existente: HP cheio, sem spawn pendente, inimigos mortos limpos
	get_tree().change_scene_to_file(MENU_SCENE)
