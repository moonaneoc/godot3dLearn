@tool
extends Node3D

const TEXTURE_SHEET_WIDTH = 8
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH
const CHUNK_SIZE = 16

func _ready():
	generate_chunk_mesh()

func generate_chunk_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	draw_block_mesh(st, Vector3(0, 0, 0), 8)

	st.generate_normals()
	st.generate_tangents()
	st.index()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = preload("res://voxel/material.tres")
	add_child(mi)

func draw_block_mesh(surface_tool, block_position, block_id):
	var vertex = [
		Vector3(block_position.x, block_position.y, block_position.z),
		Vector3(block_position.x, block_position.y, block_position.z + 1),
		Vector3(block_position.x, block_position.y + 1, block_position.z),
		Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y, block_position.z),
		Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
	]

	var row = block_id / TEXTURE_SHEET_WIDTH
	var col = block_id % TEXTURE_SHEET_WIDTH
	var uvs = [
		TEXTURE_TILE_SIZE * Vector2(col, row),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row + 1),
		TEXTURE_TILE_SIZE * Vector2(col, row + 1),
	]

	# left face
	draw_faces(surface_tool, [vertex[2], vertex[3], vertex[1], vertex[0]], uvs)
	# right face
	draw_faces(surface_tool, [vertex[7], vertex[6], vertex[4], vertex[5]], uvs)
	# top face
	draw_faces(surface_tool, [vertex[2], vertex[6], vertex[7], vertex[3]], uvs)
	# bottom face
	draw_faces(surface_tool, [vertex[1], vertex[5], vertex[4], vertex[0]], uvs)
	# forward face
	draw_faces(surface_tool, [vertex[3], vertex[7], vertex[5], vertex[1]], uvs)
	# back face
	draw_faces(surface_tool, [vertex[6], vertex[2], vertex[0], vertex[4]], uvs)

func draw_faces(surface_tool, vertex, uvs):
	surface_tool.set_uv(uvs[0]); surface_tool.add_vertex(vertex[0])
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(vertex[1])
	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(vertex[2])

	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(vertex[2])
	surface_tool.set_uv(uvs[3]); surface_tool.add_vertex(vertex[3])
	surface_tool.set_uv(uvs[0]); surface_tool.add_vertex(vertex[0])
	
