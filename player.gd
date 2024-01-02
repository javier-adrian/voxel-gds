extends CharacterBody3D

@export var acceleration: float  # 25
@export var walkSpeed: float  # 5
@export var mouseSpeed: float  # 300

@export var cam: Camera3D
@export var coords: Label
@export var fps: Label

# var velocity = Vector3.ZERO
var lookAngles = Vector2.ZERO

var sprintSpeed: float
var playerSpeed: float


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sprintSpeed = walkSpeed + (walkSpeed * .3)
	playerSpeed = walkSpeed


func _physics_process(delta):
	lookAngles.y = clamp(lookAngles.y, PI / -2, PI / 2)
	rotation = Vector3(lookAngles.y, lookAngles.x, 0)
	var direction = updateDirection()

	if direction:
		velocity = direction * playerSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, walkSpeed)
		velocity.y = move_toward(velocity.y, 0, walkSpeed)
		velocity.z = move_toward(velocity.z, 0, walkSpeed)

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
	if event is InputEventMouseMotion:
		lookAngles -= event.relative / mouseSpeed


func updateDirection():
	var horizontal = Input.get_vector("Left", "Right", "Forward", "Backward")
	var vertical = Input.get_axis("Up", "Down") * -1

	return (transform.basis * Vector3(horizontal.x, vertical, horizontal.y)).normalized()


func _process(delta):
	coords.text = (
		"XYZ: "
		+ ("%.2f" % global_position.y)
		+ " / "
		+ ("%.2f" % global_position.y)
		+ " / "
		+ ("%.2f" % global_position.z)
	)
	fps.text = str(Engine.get_frames_per_second()) + " fps"
