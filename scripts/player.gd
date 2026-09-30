extends CharacterBody2D

const GameState = preload("res://scripts/game_state.gd")
const BULLET_SCENE = preload("res://entities/bullet.tscn")

const SPEED = 100.0
const JUMP_VELOCITY = -270.0
const SHOOT_COOLDOWN := 0.3
const INVULNERABLE_TIME := 1.0
const HURT_TIME := 0.25

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var shoot_timer := 0.0
var invulnerable_timer := 0.0
var hurt_timer := 0.0
var dead := false
var falling := false
var hp_label: Label


func _ready() -> void:
	add_to_group("player")
	# HUD mínimo: vida no canto da tela.
	var layer := CanvasLayer.new()
	hp_label = Label.new()
	hp_label.position = Vector2(4, 2)
	hp_label.add_theme_font_size_override("font_size", 10)
	layer.add_child(hp_label)
	add_child(layer)
	_update_hud()


func _physics_process(delta: float) -> void:
	shoot_timer -= delta
	invulnerable_timer -= delta
	hurt_timer -= delta

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if hurt_timer > 0.0:
		# Levando dano: mantém o empurrão, sem controle.
		animated_sprite.play("hurt")
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			if direction > 0:
				animated_sprite.flip_h = false
				animated_sprite.play("walk")
			elif direction < 0:
				animated_sprite.flip_h = true
				animated_sprite.play("walk")
			else:
				animated_sprite.play("idle")
		else:
			animated_sprite.play("jump")

	# Pisca enquanto está invulnerável.
	animated_sprite.visible = invulnerable_timer <= 0.0 or int(invulnerable_timer * 20.0) % 2 == 0

	# Disparo (tecla F = ação "action").
	if Input.is_action_just_pressed("action") and shoot_timer <= 0.0 and not dead:
		_shoot()

	move_and_slide()


func _shoot() -> void:
	shoot_timer = SHOOT_COOLDOWN
	var facing := -1 if animated_sprite.flip_h else 1
	var bullet := BULLET_SCENE.instantiate()
	bullet.direction = facing
	bullet.global_position = global_position + Vector2(facing * 10, 6)
	get_parent().add_child(bullet)


func take_damage(amount: int, from_pos: Vector2) -> void:
	if invulnerable_timer > 0.0 or dead:
		return
	GameState.player_hp -= amount
	_update_hud()
	if GameState.player_hp <= 0:
		_die()
		return
	invulnerable_timer = INVULNERABLE_TIME
	hurt_timer = HURT_TIME
	var away := 1.0 if global_position.x >= from_pos.x else -1.0
	velocity = Vector2(away * 120.0, -150.0)


func fell() -> void:
	# Caiu no vazio: perde 1 de vida e recomeça a área no último spawn.
	if dead or falling:
		return
	falling = true
	GameState.player_hp -= 1
	_update_hud()
	if GameState.player_hp <= 0:
		_die()
	else:
		get_tree().reload_current_scene.call_deferred()


func _die() -> void:
	dead = true
	set_physics_process(false)
	animated_sprite.visible = true
	animated_sprite.play("hurt")
	await get_tree().create_timer(0.8).timeout
	GameState.reset()
	get_tree().change_scene_to_file(GameState.START_SCENE)


func _update_hud() -> void:
	hp_label.text = "HP: %d" % maxi(GameState.player_hp, 0)
