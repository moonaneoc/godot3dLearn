extends SubViewport

var filename = "item_bg_selected"

func _ready():
		size = Vector2(128, 128)
		render_target_update_mode = SubViewport.UPDATE_ALWAYS
		transparent_bg = true
		await RenderingServer.frame_post_draw
		var img = get_texture().get_image()
#		img.save_png("res://icon_creator/icons/" + filename +".png")
		img.save_png("res://build_system/assets/icons/" + filename +".png")
