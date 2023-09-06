class_name Spawnable
extends StaticBody3D

const FACE_FORWARD = 0b100000
const FACE_BACK = 0b010000
const FACE_LEFT = 0b001000
const FACE_RIGHT = 0b000100
const FACE_UP = 0b000010
const FACE_DOWN = 0b000001

var type_name: String # 必填 类型名
var buildable: bool = false # 是否显示在建造栏
var allow_degree: Array = [0] # 允许旋转的角度
var auto_rotate: bool = false # 是否自动调整角度，开启后会禁止手动改变角度
var build_on_list: Array = [] # 允许建造在哪些建筑上
var buildable_faces = 0 # 二进制表示允许建造的面，顺序为 前后左右上下，分别对应 0b111111

var current_degree_index = 0

func initialize(cfg):
	assert(cfg.has("type_name"), "Spawnable initialize fail,type_name can not be null")
	
	type_name = cfg.type_name
	if cfg.has("buildable"): buildable = cfg.buildable
	if cfg.has("allow_degree"): allow_degree = cfg.allow_degree
	if cfg.has("auto_rotate"): auto_rotate = cfg.auto_rotate
	if cfg.has("build_on_list"): build_on_list = cfg.build_on_list
	if cfg.has("buildable_faces"): buildable_faces = cfg.buildable_faces

func changeDirection():
	if auto_rotate: return
	
	current_degree_index += 1
	if current_degree_index > allow_degree.size() - 1:
		current_degree_index = 0
	rotation_degrees.y = allow_degree[current_degree_index]

func autoFixRotation(targetCollider):
	if(auto_rotate):
		rotation_degrees.y = targetCollider.rotation_degrees.y + 90
		
func checkSpawnable(target: Spawnable, normal: Vector3):
	for ray in get_node("CollisionShape").get_children():
		if ray.get_collider() != target:
			return 2
		
	if !build_on_list.has(target.type_name): return 1
	if !target.checkBuildableFace(normal): return 2

	return 0

func checkBuildableFace(normal):
	if buildable_faces > 0:
		if buildable_faces & FACE_FORWARD and (normal - transform.basis.z).length() < 0.001: return true
		if buildable_faces & FACE_BACK and (normal + transform.basis.z).length() < 0.001: return true
		if buildable_faces & FACE_LEFT and (normal - transform.basis.x).length() < 0.001: return true
		if buildable_faces & FACE_RIGHT and (normal + transform.basis.x).length() < 0.001: return true
		if buildable_faces & FACE_UP and (normal - transform.basis.y).length() < 0.001: return true
		if buildable_faces & FACE_DOWN and (normal + transform.basis.y).length() < 0.001: return true
	return false
