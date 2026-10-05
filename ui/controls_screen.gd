extends Control
## Tela de controles (reutilizada pelo menu principal e pelo menu de pausa).
## Use open() para mostrar; emite "closed" quando o jogador volta (botão VOLTAR ou ESC).

signal closed

@onready var back_button: Button = $Center/Panel/Box/BackButton


func _ready() -> void:
	visible = false
	back_button.pressed.connect(close)


func open() -> void:
	visible = true
	back_button.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
