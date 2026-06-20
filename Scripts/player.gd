extends CharacterBody3D


const WALK_SPEED = 3.0
const JOG_SPEED = 5.0
const SPRINT_SPEED = 7.0

const JUMP_VELOCITY = 5.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

const TPS_DISTANCE = 3.0
const FPS_DISTANCE = 0.0
var target_distance = TPS_DISTANCE
const TPS_OFFSET := Vector3(0.0, 1.7, 0.0)
const FPS_OFFSET := Vector3(0.4, 1.7, 0.0) # Right shoulder
var target_offset := TPS_OFFSET

@export var sensitivity := 0.1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event.is_action_pressed("toggle_view"):
		if target_distance == TPS_DISTANCE:
			target_distance = FPS_DISTANCE
			target_offset = FPS_OFFSET
		else:
			target_distance = TPS_DISTANCE
			target_offset = TPS_OFFSET

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate player (left/right)
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))

		# Rotate camera (up/down)
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * sensitivity))

		# Clamp vertical rotation
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x,
			deg_to_rad(-45),
			deg_to_rad(60)
		)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Smooth camera distance
	spring_arm.spring_length = lerp(
		spring_arm.spring_length,
		target_distance,
		8.0 * delta
	)

	# Smooth shoulder movement
	spring_arm.position = spring_arm.position.lerp(
		target_offset,
		8.0 * delta
	)

	# Hide player mesh in FPS
	mesh.visible = spring_arm.spring_length > 0.2
	
	
	# Movement
	var input_dir := Input.get_vector("UI_Left", "UI_Right", "UI_Up", "UI_Down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Default movement is jogging
	var current_speed = JOG_SPEED

	# Hold Ctrl to walk
	if Input.is_action_pressed("walk"):
		current_speed = WALK_SPEED

	# Hold Shift to sprint
	elif Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO:
		current_speed = SPRINT_SPEED
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
