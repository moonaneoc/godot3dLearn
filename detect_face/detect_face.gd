extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("LeftMouseButton"):
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
		var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if !result.is_empty():
			$ball.transform.origin = result.position
			print(result.normal)
			print(result.collider.transform.basis.z)
			if (result.normal - result.collider.transform.basis.z).length() < 0.001:
				print("forward")
			elif (result.normal - -result.collider.transform.basis.z).length() < 0.001:
				print("back")
			elif (result.normal - result.collider.transform.basis.x).length() < 0.001:
				print("right")
			elif (result.normal - -result.collider.transform.basis.x).length() < 0.001:
				print("left")
			elif (result.normal - result.collider.transform.basis.y).length() < 0.001:
				print("up")
			elif (result.normal - -result.collider.transform.basis.y).length() < 0.001:
				print("down")
