extends Spatial


export(NodePath) var storage_children_root

var nr_positions = 0
var free_positions setget ,get_free_positions
var box_positions setget ,get_box_positions

var _storage_children


func _ready():
	if not storage_children_root:
		storage_children_root = @"."
	
	_storage_children = get_node(storage_children_root).get_children()
	
	for child in _storage_children:
		nr_positions += child.nr_positions


func get_free_positions():
	var positions = []
	var offset = 0
	
	for child in _storage_children:
		for position in child.free_positions:
			positions.push_back(position + offset)
		
		offset += child.nr_positions
	
	return positions


func get_box_positions():
	var positions = []
	var offset = 0
	
	for child in _storage_children:
		for position in child.box_positions:
			positions.push_back(position + offset)
		
		offset += child.nr_positions
	
	return positions


func add_box(pos, box):
	for child in _storage_children:
		if pos < child.nr_positions:
			return child.add_box(pos, box)
		pos -= child.nr_positions


func get_space(pos):
	for child in _storage_children:
		if pos < child.nr_positions:
			return child.get_space(pos)
		pos -= child.nr_positions


func fill(box: PackedScene):
	for child in _storage_children:
		child.fill(box)
