extends StaticBody


var free_positions setget ,get_free_positions
var box_positions setget ,get_box_positions

onready var _spaces = $Spaces.get_children()
onready var nr_positions = _spaces.size()


func get_free_positions():
	var positions = []
	
	for pos in nr_positions:
		if not has_box(pos):
			positions.push_back(pos)
	
	return positions


func get_box_positions():
	var positions = []
	
	for pos in nr_positions:
		if has_box(pos):
			positions.push_back(pos)
	
	return positions


func add_box(pos, box):
	var space = _spaces[pos]
	
	space.add_child(box)
	box.translation = Vector3()
	
	box.set_owner(space)


func get_space(pos):
	return _spaces[pos]


func has_box(pos):
	return get_space(pos).box != null


func fill(box: PackedScene):
	for pos in len(_spaces):
		if not has_box(pos):
			add_box(pos, box.instance())
