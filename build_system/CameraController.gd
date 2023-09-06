class_name CameraController
extends Node3D

const MIN_FOV = 50
const MAX_FOV = 110
const ZOOM_SPEED = 0.2

var target_fov: float

var MousePos
var isDragging = false
var mouse_in_gui = false

@onready var camera: Camera3D = get_node("Camera3D")

func _ready():
	target_fov = camera.fov

func _process(delta):
	camera.fov = lerp(camera.fov, target_fov, ZOOM_SPEED)
	
	if isDragging:
		var pos = get_viewport().get_mouse_position()
		var dir : Vector2 = pos - MousePos;
		rotate_y(-dir.x * delta * 0.5)
		rotate(transform.basis.x, -dir.y * delta * 0.5)
		MousePos = pos
		transform = transform.orthonormalized()
		
	if !mouse_in_gui:
		if Input.is_action_just_pressed("MiddleMouseUp"):
			target_fov = clamp(target_fov - ZOOM_SPEED * 40, MIN_FOV, MAX_FOV)
		elif Input.is_action_just_pressed("MiddleMouseDown"):
			target_fov = clamp(target_fov + ZOOM_SPEED * 40, MIN_FOV, MAX_FOV)
	
	if Input.is_action_just_pressed("LeftMouseButton") and !mouse_in_gui and BuildManager.CurrentState == BuildManager.State.Play:
		MousePos = get_viewport().get_mouse_position()
		isDragging = true
	if Input.is_action_just_released("LeftMouseButton"):
		isDragging = false

func _on_gui_build_item_mouse_entered(type_name):
	mouse_in_gui = true

func _on_gui_build_item_mouse_exited(type_name):
	mouse_in_gui = false

func _on_gui_mouse_entered():
	pass # Replace with function body.

func _on_gui_mouse_exited():
	pass # Replace with function body.
