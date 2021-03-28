extends Spatial


var rng = RandomNumberGenerator.new()
var box_packed = preload("res://scenes/Box.tscn")

onready var _robot = $Robot
onready var _source_section = $Sections/Section
onready var _target_section = $Sections/Section2


func _ready():
	rng.randomize()
	
	_source_section.fill(box_packed)


# pick a random space with a box from the source section
func random_source():
	var positions = _source_section.get_box_positions()
	var pos = positions[rng.randi() % positions.size()]
	
	return _source_section.get_space(pos)


# pick a random empty space from the target section
func random_target():
	var positions = _target_section.get_free_positions()
	var pos = positions[rng.randi() % positions.size()]
	
	return _target_section.get_space(pos)


func move_random_box():
	var source = random_source()
	source.box.highlight = true
	
	var target = random_target()
	target.highlight = true
	
	_robot.pick_box(source)
	
	yield(_robot, "box_picked")
	
	_robot.place_box(target)


func start_robot():
	move_random_box()


func _on_Robot_box_placed():
	if _source_section.get_box_positions().size():
		move_random_box()
	else:
		_robot.move_to(Vector3(), 90)
