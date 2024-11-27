@tool
extends EditorPlugin
class_name BMPI

var dock;
var has_dock := false;

static var preview: EditorResourcePreview;

func _enter_tree() -> void:
	get_editor_interface().get_selection().selection_changed.connect(_selection_changed);
	preview = get_editor_interface().get_resource_previewer();

static func get_scene_preview(scene : String, reciever : Object, function : String):
	preview.queue_resource_preview(scene, reciever, function, null);

func _selection_changed():
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes();
	if(!selected_nodes.is_empty()):
		var selected = selected_nodes[0];
		if(selected is MultiplayerSpawner):
			_add_panel(selected);
			return;	
	_remove_panel();

func _exit_tree() -> void:
	_remove_panel();

func _add_panel(spawner : MultiplayerSpawner):
	if(!has_dock):
		dock = preload("res://addons/better_mp_spawner_interface/ui/better_spawner_tab.tscn").instantiate();
		dock.mp_spawner = spawner;
		dock.plugin = self;
		add_control_to_bottom_panel(dock, "MP Spawner");
		make_bottom_panel_item_visible(dock);
		has_dock = true;

func _remove_panel():
	if(has_dock):
		remove_control_from_bottom_panel(dock);
		has_dock = false;
