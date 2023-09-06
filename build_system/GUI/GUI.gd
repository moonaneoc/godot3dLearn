extends ScrollContainer

signal build_btn_click
signal build_item_mouse_entered
signal build_item_mouse_exited

const ICON_PATH = "res://build_system/assets/icons/"

@onready var container = $BoxContainer
@onready var GuiItem: PackedScene = ResourceLoader.load("res://build_system/GUI/GUI_item.tscn")

func loadIcon(type_name):
	var icon = ResourceLoader.load(ICON_PATH + type_name + ".png")
	var guiItem = GuiItem.instantiate()
	guiItem.type_name = type_name
	guiItem.get_node("icon").texture = icon
	container.add_child(guiItem)
	guiItem.build_item_click.connect(_on_build_btn_click)
	guiItem.build_item_mouse_entered.connect(_on_build_item_mouse_entered)
	guiItem.build_item_mouse_exited.connect(_on_build_item_mouse_exited)
		
func _on_build_btn_click(type_name):
	build_btn_click.emit(type_name)

func _on_build_item_mouse_entered(type_name):
	build_item_mouse_entered.emit(type_name)

func _on_build_item_mouse_exited(type_name):
	build_item_mouse_exited.emit(type_name)
