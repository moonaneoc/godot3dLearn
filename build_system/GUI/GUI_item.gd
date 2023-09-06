extends TextureRect

signal build_item_click
signal build_item_mouse_entered
signal build_item_mouse_exited

var type_name

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		build_item_click.emit(type_name)


func _on_mouse_entered():
	build_item_mouse_entered.emit(type_name)

func _on_mouse_exited():
	build_item_mouse_exited.emit(type_name)
