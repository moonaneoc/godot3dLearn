class_name BuildManager
extends Node3D

static var State = {
	Play = 0,
	Building = 1,
	Destroying = 2
}
static var CurrentState = State.Play

@onready var BuildingContainer = $BuildingContainer

const STEP_SIZE := 0.2
const SCENE_PATH := "res://build_system/scenes/"
const COLOR_ABLE := Color("26bf3664")
const COLOR_DISABLE := Color("bf262964")

var SpawnableCfg
var SceneResource = {}
var CurrentSpawnable: StaticBody3D
var Buildable = false
var IsSaving = false

var assist_point:MeshInstance3D
func _ready():
	assist_point = get_tree().root.get_node("BuildSystem/assist_point")
	
#	var configDebug = ConfigFile.new()
#	configDebug.set_value("cabinet", "type_name", "cabinet")
#	configDebug.set_value("cabinet", "buildable", true)
#	configDebug.set_value("cabinet", "allow_degree", [0, 90])
#	configDebug.set_value("cabinet", "auto_rotate", false)
#	configDebug.set_value("cabinet", "build_on_list", ["floor"])
#	configDebug.save("res://build_system/spawnable.cfg")
	
	SpawnableCfg = CommonTools.loadCfgToDictionary("res://build_system/spawnable.cfg")
	for key in SpawnableCfg:
		var type_name = SpawnableCfg[key].type_name
		SceneResource[type_name] = ResourceLoader.load(SCENE_PATH + type_name + ".tscn");
		if SpawnableCfg[key].has("buildable") and SpawnableCfg[key].buildable:
			$GUI.loadIcon(type_name)
	
	var floor:Spawnable = SceneResource["floor"].instantiate()
	floor.initialize(SpawnableCfg["floor"])
	var wall1:Spawnable = SceneResource["wall"].instantiate()
	wall1.initialize(SpawnableCfg["wall"])
	var wall2:Spawnable = SceneResource["wall"].instantiate()
	wall2.initialize(SpawnableCfg["wall"])
	floor.transform.origin = Vector3.ZERO
	wall1.transform.origin = Vector3(-3.6, 0, 0)
	wall2.transform.origin = Vector3(0, 0, -3.6)
	wall2.rotation_degrees.y = -90
	add_child(floor)
	add_child(wall1)
	add_child(wall2)
	
	loadData()

func _physics_process(delta):
	if handleInput(): return
	updateSpanwable()

func handleInput():
	if Input.is_action_just_pressed("Clean"):
		for child in BuildingContainer.get_children():
			child.queue_free()
		return true

	if Input.is_action_just_pressed("RightMouseButton"):
		if CurrentState == State.Building:
			CurrentSpawnable.queue_free()
			CurrentState = State.Play
			$GUI.active_name = ""
			return true
		
		var result = rayToWorld()
		if !result.is_empty():
			if(result.collider.type_name != "floor" and result.collider.type_name != "wall"):
				result.collider.queue_free()
				$Remove.play()
				return true
	
	if Input.is_action_just_pressed("LeftMouseButton") and CurrentState == State.Building and Buildable:
		spawnBuilding(CurrentSpawnable.type_name, CurrentSpawnable.transform)
		$Spawn.play()
		return
		
	if Input.is_action_just_pressed("Rotate") && CurrentState == State.Building:
		CurrentSpawnable.changeDirection()

func updateSpanwable():
	if CurrentState != State.Building: return
	
	CurrentSpawnable.visible = false
	Buildable = false
	var result = rayToWorld()
	if !result.is_empty():
		autoFixOrigin(CurrentSpawnable, result.position, result.normal)
		CurrentSpawnable.autoFixRotation(result.collider)
		match CurrentSpawnable.checkSpawnable(result.collider, result.normal):
			0:
				assist_point.transform.origin = CurrentSpawnable.transform.origin
				CurrentSpawnable.visible = true
				Buildable = true
				CurrentSpawnable.get_node("MeshInstance").set("instance_shader_parameters/instance_color", COLOR_ABLE)
			1:
				CurrentSpawnable.visible = true
				CurrentSpawnable.get_node("MeshInstance").set("instance_shader_parameters/instance_color", COLOR_DISABLE)

func rayToWorld():
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	return result
	
func spawnBuilding(type_name, transformObj):
	var spawnable:Spawnable = SceneResource[type_name].instantiate()
	spawnable.initialize(SpawnableCfg[type_name])
	spawnable.transform = transformObj
	BuildingContainer.add_child(spawnable)

func autoFixOrigin(CurrentSpawnable, pos, normal):
	var posX = (floor(pos.x / STEP_SIZE)) * STEP_SIZE if abs(normal.x) < 0.01 else pos.x
	var posY = (floor(pos.y / STEP_SIZE)) * STEP_SIZE if abs(normal.y) < 0.01 else pos.y
	var posZ = (floor(pos.z / STEP_SIZE)) * STEP_SIZE if abs(normal.z) < 0.01 else pos.z
	CurrentSpawnable.transform.origin = Vector3(posX, posY, posZ);
	
func loadData():
	var file_access := FileAccess.open("user://build_system.save", FileAccess.READ)
	if file_access != null:
		var data = file_access.get_var()
		if data != null:
			for item in data:
				spawnBuilding(item[0], item[1])
	
func saveData():
	if IsSaving: return
	
	IsSaving = true
	await get_tree().create_timer(1).timeout
	IsSaving = false
	
	var data: Array = []
	for child in BuildingContainer.get_children():
		if !child.is_queued_for_deletion():
			data.push_back([child.type_name, child.transform])
			
	var file_access := FileAccess.open("user://build_system.save", FileAccess.WRITE)
	var err := FileAccess.get_open_error()
	if file_access == null or err != OK:
		saveData()
	else:
		file_access.store_var(data)
		
func _on_gui_build_btn_click(type_name):
	if CurrentState == State.Building:
		CurrentSpawnable.queue_free()
		if type_name == CurrentSpawnable.type_name:
			CurrentState = State.Play
			$GUI.active_name = ""
			return
	
	CurrentState = State.Building
	Buildable = false
	
	CurrentSpawnable = SceneResource[type_name].instantiate()
	CurrentSpawnable.initialize(SpawnableCfg[type_name])
	CurrentSpawnable.visible = false
	CurrentSpawnable.get_node("CollisionShape").disabled = true
	var model: MeshInstance3D = CurrentSpawnable.get_node("MeshInstance")
	model.material_override = load("res://build_system/assets/material/placer.tres")
	model.set("instance_shader_parameters/instance_color", COLOR_ABLE)
	for ray in CurrentSpawnable.get_node("CollisionShape").get_children():
		ray.enabled = true
	add_child(CurrentSpawnable)
	$GUI.active_name = type_name
	
func _on_building_container_child_entered_tree(node):
	saveData()

func _on_building_container_child_exiting_tree(node):
	saveData()
