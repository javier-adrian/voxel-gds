
extends CharacterBody3D

@export var jump: float
@export var walkSpeed: float
@export var sensitivity: float

@export var head: Node3D
@export var cam: Camera3D
@export var RayCast: RayCast3D
@export var highlighter: MeshInstance3D
@export var coords: Label
@export var fps: Label
@export var gamemode: Label
@export var targeted: Label
@export var facing: Label
@export var chunk: Label
@export var survival: bool

var lookAngles = Vector2.ZERO

var targetedBlock: String
var looking_at: Vector2
var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var distances : Array[float] = [0, 0, 0, 0]
var directions_string := ["east [+X]", "west [-X]", "south [+N]", "north [-N]"]

var sprintSpeed: float
var playerSpeed: float
var camXRotation: float = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var blockManager = get_node(^"/root/Level/BlockManager")
@onready var chunkManager = get_node(^"/root/Level/ChunkManager")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sprintSpeed = walkSpeed + (walkSpeed * .3)
	playerSpeed = walkSpeed


func _physics_process(delta):
	if !is_on_floor() && survival:
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("Up") && is_on_floor() && survival:
		velocity.y = jump

	var horizontal = Input.get_vector("Left", "Right", "Backward", "Forward").normalized()

	var direction = Vector3.ZERO

	direction += horizontal.x * head.global_basis.x
	direction += horizontal.y * -head.global_basis.z

	if !survival:
		var vertical = Input.get_axis("Up", "Down") * -1
		velocity.y = vertical * gravity

	velocity.x = direction.x * playerSpeed
	velocity.z = direction.z * playerSpeed

	if Input.is_action_pressed("Sprint") and direction != Vector3.ZERO:
		playerSpeed = sprintSpeed
		var speedTween = get_tree().create_tween()
		speedTween.tween_property(cam, "fov", 90, .25)
	if Input.is_action_just_released("Sprint"):
		playerSpeed = walkSpeed
		var speedTween = get_tree().create_tween()
		speedTween.tween_property(cam, "fov", 75, .25)

	move_and_slide()

func _input(event):
	if Input.is_physical_key_pressed(KEY_F4):
		survival = false if survival else true
	if Input.is_physical_key_pressed(KEY_F1):
		coords.visible = false if coords.visible else true
		fps.visible = false if fps.visible else true
		gamemode.visible = false if gamemode.visible else true
	if event is InputEventMouseMotion:
		var mouseMotion = event as InputEventMouseMotion
		lookAngles.x = mouseMotion.relative.y * sensitivity
		lookAngles.y = -mouseMotion.relative.x * sensitivity

		head.rotate_y(deg_to_rad(lookAngles.y))
		if camXRotation + lookAngles.x > -90 && camXRotation + lookAngles.x < 90:
			cam.rotate_x(deg_to_rad(-lookAngles.x))
			camXRotation += lookAngles.x
	
	looking_at = Vector2.RIGHT.rotated(round(head.rotation.y / TAU * 8) * TAU / 8).snapped(Vector2.ONE)

	for i in len(directions):
		distances[i] = directions[i].distance_to(looking_at)
	
	facing.text = "Facing: %s" % str(directions_string[distances.find(distances.min())])

func _process(delta):
	highlighter.visible = RayCast.is_colliding()

	if RayCast.is_colliding() && RayCast.get_collider() is Chunk:
		var chunk = RayCast.get_collider()
		highlighter.visible = true


		var blockPosition = RayCast.get_collision_point() - 0.5 * RayCast.get_collision_normal()
		var intBlockPosition = Vector3i(floori(blockPosition.x), floori(blockPosition.y), floori(blockPosition.z))

		targetedBlock = chunk.getBlock(Vector3i(intBlockPosition - Vector3i(chunk.global_position)))
		targeted.text = "Targeted block: " + targetedBlock + " (" +str(intBlockPosition.x) + " / " + str(intBlockPosition.y) + " / " + str(intBlockPosition.z) + ")"
 
		highlighter.global_position = Vector3(intBlockPosition) + Vector3(0.5, 0.5, 0.5)

		if Input.is_action_just_pressed("Break"):
			chunk.setBlock(Vector3i(intBlockPosition - Vector3i(chunk.global_position)), blockManager.air)
		if Input.is_action_just_pressed("Place"):
			chunkManager.setBlock(Vector3i(intBlockPosition + Vector3i(RayCast.get_collision_normal())), blockManager.stone)
	else:
		highlighter.visible = false
		targeted.text = "Targeted block: none"

	coords.text = (
		"XYZ: "
		+ ("%.2f" % global_position.x)
		+ " / "
		+ ("%.2f" % global_position.y)
		+ " / "
		+ ("%.2f" % global_position.z)
	)
	fps.text = str(Engine.get_frames_per_second()) + " fps"
	gamemode.text = "survival" if survival else "creative"

	chunk.text = "Chunk: " + str(floori(global_position.x / 32)) + " / " + str(floori(global_position.z / 32))
