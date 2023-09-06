extends Node3D

var filename = "temp"

func _ready():
	for child in get_children():
		await RenderingServer.frame_post_draw
		var img = child.get_texture().get_image()
#		img.save_png("res://icon_creator/icons/" + filename +".png")
		img.save_png("res://build_system/assets/icons/" + filename +".png")
