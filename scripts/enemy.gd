extends CharacterBody2D
## Inimigo básico (Robot Walky): patrulha na horizontal, vira em parede/beirada,
## tem vida, sofre dano dos projéteis, causa dano ao encostar no player e morre.

const GameState = preload("res://scripts/game_state.gd")

const SPEED := 30.0

@export var max_hp := 3
@export var patrol_range := 60.0   # distância máxima do ponto inicial

var hp := 3
var dir := -1
var origin_x := 0.0
var hurt_time := 0.0
var turn_cooldown := 0.0
var key := ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ledge_ray: RayCast2D = $LedgeRay
@onready var hitbox: Area2D = $Hitbox


func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	origin_x = global_position.x
	# Inimigo já morto nesta área não volta quando o player retorna.
	key = (owner.scene_file_path if owner else "") + ":" + str(name)
	if GameState.killed.has(key):
		queue_free()
		return
	sprite.play("walk")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	hurt_time -= delta
	turn_cooldown -= delta

	if hurt_time > 0.0:
		velocity.x = 0.0
	else:
		if turn_cooldown <= 0.0:
			var too_far := absf(global_position.x - origin_x) > patrol_range and signf(global_position.x - origin_x) == dir
			var at_ledge := is_on_floor() and not ledge_ray.is_colliding()
			if is_on_wall() or at_ledge or too_far:
				_turn()
		velocity.x = dir * SPEED
		if sprite.animation != &"walk":
			sprite.play("walk")

	sprite.flip_h = dir > 0
	move_and_slide()

	# Dano de contato no player.
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(1, global_position)


func _turn() -> void:
	dir = -dir
	turn_cooldown = 0.3
	ledge_ray.position.x = 9.0 * dir
	ledge_ray.force_raycast_update()


func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp -= amount
	if hp > 0:
		hurt_time = 0.2
		sprite.play("hurt")
		return
	# Morte: some com um fade rápido.
	GameState.killed[key] = true
	remove_from_group("enemy")
	set_physics_process(false)
	hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.play("hurt")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
