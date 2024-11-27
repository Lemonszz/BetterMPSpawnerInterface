@tool
extends VBoxContainer
class_name BetterSpawnerTab

@onready var add_button = %AddButton;
@onready var spawnables = %SpawnableScenes;
@onready var file_selector = %FileDialog;

var mp_spawner : MultiplayerSpawner;
var display_scene : PackedScene = preload("res://addons/better_mp_spawner_interface/ui/spawnable_display.tscn");
var undo_redo : EditorUndoRedoManager;
var plugin : EditorPlugin;
var resource_picker : EditorResourcePicker;

func _ready() -> void:
	undo_redo = plugin.get_undo_redo();
	
	_set_icons();
	_add_scenes();
	
	spawnables.data_dropped.connect(_data_dropped);
	add_button.pressed.connect(func(): file_selector.popup());
	file_selector.files_selected.connect(_files_selected);

func remove_spawnable(scene : String, create_action : bool = true):
	var current = [];
	var new = [];
	for i in range(mp_spawner.get_spawnable_scene_count()):
		var s = mp_spawner.get_spawnable_scene(i);
		current.append(s);
		new.append(s);
	new.erase(scene);
	
	mp_spawner.clear_spawnable_scenes();
	for sc in current:
		mp_spawner.add_spawnable_scene(sc);
	_add_scenes();
	
	if(create_action):
		undo_redo.create_action("Remove Spawnable Scene");
		undo_redo.add_do_method(self, "_set_scenes", new);
		undo_redo.add_undo_method(self, "_set_scenes", current);
		undo_redo.commit_action();
	else:
		_set_scenes(new);
	plugin.get_editor_interface().mark_scene_as_unsaved();

func _set_scenes(scenes):
	mp_spawner.clear_spawnable_scenes();
	for sc in scenes:
		mp_spawner.add_spawnable_scene(sc);
	_add_scenes();
	plugin.get_editor_interface().mark_scene_as_unsaved();
	
func _data_dropped(data: Variant) -> void:
	var files : PackedStringArray = data["files"];
	add_files_from_array(files);
	
func add_files_from_array(files : PackedStringArray):
	files = Array(files).filter(func(s : String): return !has_spawnable(s) && s.ends_with(".tscn"));
	if(files.is_empty()):
		return;
	
	undo_redo.create_action("Add Spawnable Scenes");
	undo_redo.add_do_method(self, "_add_spawnables", files);
	undo_redo.add_undo_method(self, "_remove_spawnables", files);
	undo_redo.commit_action()
	
func _remove_spawnables(files):
	for file in files:
		remove_spawnable(file, false);
	
func _add_spawnables(files) -> Array:
	var added : Array = [];
	for file in files:
		if(add_spawnable(file, false, false)):
			added.append(file);
	_add_scenes();
	return added;

func add_spawnable(scene : String, update_panel : bool = true, create_action : bool = true) -> bool:
	if(!has_spawnable(scene)):
		undo_redo.create_action("Add Spawnable Scene");
		undo_redo.add_do_method(self, "_mp_spawner_add", scene);
		undo_redo.add_undo_method(self, "remove_spawnable", scene, false);
		undo_redo.commit_action()
		if(update_panel):
			_add_scenes();
		plugin.get_editor_interface().mark_scene_as_unsaved();
		return true;
	return false;
	
func _mp_spawner_add(scene):
	print(101112);
	mp_spawner.add_spawnable_scene(scene);
		
func has_spawnable(scene : String) -> bool:
	for i in range(mp_spawner.get_spawnable_scene_count()):
		var sc = mp_spawner.get_spawnable_scene(i);
		if(sc == scene):
			return true;
	return false;


func _free_all(node : Node):
	for ch in node.get_children():
		ch.queue_free();
	
func _files_selected(files):
	add_files_from_array(files);

## Add Scenes to panel
func _add_scenes():
	_free_all(spawnables);
	if(mp_spawner):
		for i in range(mp_spawner.get_spawnable_scene_count()):
			var sc = mp_spawner.get_spawnable_scene(i);
			var display = display_scene.instantiate();
			display.scene = sc;
			display.panel = self;
			spawnables.add_child(display);
		mp_spawner.notify_property_list_changed();

## Set panel styles
func _set_icons():
	add_button.icon = get_theme_icon("Add", "EditorIcons");
	%ScenesBackground.add_theme_stylebox_override("panel", get_theme_stylebox("Background", "EditorStyles")); 
