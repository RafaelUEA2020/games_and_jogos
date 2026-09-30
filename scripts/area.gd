extends Node2D
## Script da raiz de cada área: posiciona o player no spawn certo,
## ajusta os limites da câmera e trata queda no vazio.

const GameState = preload("res://scripts/game_state.gd")

@export var limit_left := 0
@export var limit_right := 288
@export var limit_top := 0
@export var limit_bottom := 208

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	if GameState.next_spawn != "":
		var spawn := get_node_or_null("Spawns/" + GameState.next_spawn)
		if spawn:
			player.global_position = spawn.global_position
	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_left = limit_left
	cam.limit_right = limit_right
	cam.limit_top = limit_top
	cam.limit_bottom = limit_bottom
	cam.reset_smoothing()


func _physics_process(_delta: float) -> void:
	# Impede o player de sair pelas laterais da área.
	player.global_position.x = clampf(player.global_position.x, limit_left + 8, limit_right - 8)
	# Caiu no vazio.
	if player.global_position.y > limit_bottom + 48 and player.has_method("fell"):
		player.fell()
