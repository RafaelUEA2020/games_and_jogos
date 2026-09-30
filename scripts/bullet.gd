extends Area2D
## Projétil do player: anda na horizontal, causa 1 de dano no inimigo
## e some ao acertar algo (inimigo ou cenário) ou após LIFETIME segundos.

const SPEED := 220.0
const LIFETIME := 0.9

var direction := 1   # 1 = direita, -1 = esquerda (definido por quem cria o projétil)
var life := LIFETIME


func _ready() -> void:
	collision_layer = 0
	collision_mask = 5  # 1 = cenário, 4 = inimigos
	body_entered.connect(_on_body_entered)
	$Sprite2D.flip_h = direction < 0


func _physics_process(delta: float) -> void:
	position.x += direction * SPEED * delta
	life -= delta
	if life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(1)
	queue_free()
