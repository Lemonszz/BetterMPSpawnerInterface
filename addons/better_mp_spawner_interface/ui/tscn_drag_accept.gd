@tool
extends HFlowContainer

signal data_dropped(data);

func _can_drop_data(position: Vector2, data) -> bool:
	if(!(data is Dictionary) ||  !("type" in data)):
		return false;
	
	if(data.type != "files"):
		return false;
	
	return true;

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data_dropped.emit(data);
