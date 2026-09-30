extends Area2D
## Saída de área: quando o player encosta, carrega a cena de destino
## e pede para ele aparecer no Marker2D "target_spawn" (dentro de "Spawns").

const GameState = preload("res://scripts/game_state.gd")

@export_file("*.tscn") var target_scene := ""
@export var target_spawn := ""


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # layer do player
	body_entered.connect(_on_body_entered)
	# Só ativa depois de um instante: evita disparar com a posição inicial do player
	# (antes de area.gd movê-lo para o spawn).
	monitoring = false
	await get_tree().create_timer(0.25).timeout
	monitoring = true


func _on_body_entered(body: Node2D) -> void:
	if target_scene == "" or not body.is_in_group("player"):
		return
	GameState.next_spawn = target_spawn
	get_tree().change_scene_to_file.call_deferred(target_scene)
