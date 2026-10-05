extends CharacterBody2D

enum PlayerState {
	idle,
	jump,
	walk,
	dead,
	
}




const SPEED = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var max_speed = 100.0
@export var acceleration= 400
@export var desaceleration = 400
@export var slide_decelaration = 100

const JUMP_VELOCITY = -300.0

var jump_count = 0
@export var max_jump_count = 2
var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.dead:
			dead_state(delta)
	move_and_slide()
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
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

func go_to_idle_state():
	status = PlayerState.idle
	animated_sprite.play("idle")
func go_to_walk_state():
	status = PlayerState.walk
	animated_sprite.play("walk")
func go_to_jump_state():
	status = PlayerState.jump
	animated_sprite.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count +=1
func go_to_dead_state():
	status = PlayerState.dead
	animated_sprite.play("dead")
	velocity = Vector2.ZERO
	
func idle_state(delta):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	if !is_on_floor():
		jump_count +=1
		go_to_idle_state()
		return
func walk_state(delta):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	if !is_on_floor():
		jump_count +=1
		go_to_idle_state()
		return
func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
func dead_state(_delta):
	pass
func move(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, desaceleration * delta)	
func update_direction():
	direction = Input.get_axis("left","right")
	
	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false
		
func can_jump() -> bool:
	return jump_count < max_jump_count
func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.shape.position.y = 3

func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.shape.position.y = 0


func _on_hitbox_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		area.get_parent().queue_free()
		go_to_jump_state()
	else:
		go_to_dead_state()
