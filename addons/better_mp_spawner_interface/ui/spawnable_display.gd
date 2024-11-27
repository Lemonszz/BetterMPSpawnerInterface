@tool
extends PanelContainer

@onready var delete_button := %DeleteButton;
@onready var scene_texture := %SceneTexture;
@onready var label := %Label;

var scene : String;
var panel : BetterSpawnerTab;

func _ready() -> void:
	_set_icons()
	_set_texture();
	
	delete_button.pressed.connect(_remove)
	if(!scene.is_empty()):
		tooltip_text = "%s\n%s" % [scene.get_file(), scene];
		label.text = scene.get_file().get_slice(".", 0);
	
func _remove():
	panel.remove_spawnable(scene);

func _set_texture():
	BMPI.get_scene_preview(scene, self, "_preview_set");
	
func _preview_set(path : String, preview : Texture2D, thumbnail_preview : Texture2D, userdata : Variant):
	scene_texture.texture = preview;
	
func _set_icons():
	delete_button.icon = get_theme_icon("Remove", "EditorIcons");
	add_theme_stylebox_override("panel", get_theme_stylebox("Content", "EditorStyles"));
