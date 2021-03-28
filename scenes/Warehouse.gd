extends Spatial


var rng = RandomNumberGenerator.new()
var box_packed = preload("res://scenes/Box.tscn")

onready var _robot = $Robot
onready var _camera_rig = $CameraRig
onready var _source_section = $Sections/Section
onready var _target_section = $Sections/Section2
onready var _lanes = $Lanes


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
	
	var via = _calc_via(source)
	
	_robot.pick_box(source, via)
	
	yield(_robot, "box_picked")
	
	via = _calc_via(target)
	
	_robot.place_box(target, via)


func start_robot():
	_robot.lane = _lanes.get_lane(_robot)
	move_random_box()


func _calc_via(space):
	var via = []
	
	var space_lane = _lanes.get_lane(space)
	if space_lane != _robot.lane:
		var space_position = space.get_parent().to_global(space.translation)
		var avg_pos = (_robot.translation + space_position) / 2
		
		via.push_back(_robot.lane.get_closest_nav_point(avg_pos))
		via.push_back(space_lane.get_closest_nav_point(avg_pos))
	
	return via


func _on_Robot_box_placed():
	if _source_section.get_box_positions().size():
		move_random_box()
	else:
		_robot.move_to(Vector3())
		_robot.move_arm(90, 2.15)


func _on_Lane_entered(lane):
	_robot.lane = lane
	_camera_rig.move_to(lane.translation)
