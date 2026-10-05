extends RefCounted
## Estado compartilhado entre as áreas (sem autoload: variáveis estáticas).
## Uso nos outros scripts:
##   const GameState = preload("res://scripts/game_state.gd")

const START_SCENE := "res://scenes/game.tscn"
const MAX_HP := 5

static var next_spawn := ""        # nome do Marker2D (em "Spawns") onde o player aparece
static var player_hp := MAX_HP     # vida do player, mantida entre as áreas
static var killed := {}            # inimigos já mortos ("cena:nome" -> true)


static func reset() -> void:
	next_spawn = ""
	player_hp = MAX_HP
	killed.clear()
