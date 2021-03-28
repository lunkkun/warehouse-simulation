extends KinematicBody


signal box_picked
signal box_placed

const APPROACH_DISTANCE = 1.5
const PICK_DISTANCE = 0.74
const PICK_HEIGHT = 0.25
const TRAVEL_SPEED = 4.0
const ROTATE_SPEED = 180.0
const ARM_SPEED = 2.0
const PICK_SPEED = 2.0

onready var _arm = $Arm
onready var _box_holder = $Arm/BoxHolder
onready var _tween = $Tween


func pick_box(space):
	_pick_or_place_box(space, true)


func place_box(space):
	_pick_or_place_box(space)


func _pick_or_place_box(space, pick_box = false):
	_move_to_approach_position(space)
	
	yield(_tween, "tween_all_completed")
	
	var approach_position = translation
	_move_to_pick_position(space)
	
	yield(_tween, "tween_all_completed")
	
	_pick_or_place(space, pick_box)
	_move_back(approach_position)
	
	yield(_tween, "tween_all_completed")
	
	# fix floating point errors
	transform = transform.orthonormalized()
	
	if pick_box:
		emit_signal("box_picked")
	else:
		emit_signal("box_placed")

func _move_to_approach_position(space):
	var space_position = space.get_parent().to_global(space.translation)
	var approach_position = space.get_parent().to_global(space.translation - space.approach_dir * APPROACH_DISTANCE)
	var approach_dir = (space_position - approach_position).normalized()
	
	var rotation_angle = (-transform.basis.z).angle_to(approach_dir) * 180 / PI
	var rotation_y = round(rotation_degrees.y + rotation_angle)
	
	var arm_height = approach_position.y + PICK_HEIGHT
	var arm_distance = abs(_arm.translation.y - arm_height)
	
	approach_position.y = 0
	var distance = translation.distance_to(approach_position)
	
	_tween.interpolate_property(self, "translation", null, approach_position, distance / TRAVEL_SPEED)
	_tween.interpolate_property(self, "rotation_degrees:y", null, rotation_y, rotation_angle / ROTATE_SPEED)
	_tween.interpolate_property(_arm, "translation:y", null, arm_height, arm_distance / ARM_SPEED)
	_tween.start()


func _move_to_pick_position(space):
	var pick_position = space.get_parent().to_global(space.translation - space.approach_dir * PICK_DISTANCE)
	pick_position.y = 0
	var distance = translation.distance_to(pick_position)
	
	_tween.interpolate_property(self, "translation", null, pick_position, distance / PICK_SPEED)
	_tween.start()


func _pick_or_place(space, pick_box):
	var box = space.box if pick_box else _box_holder.get_child(0)
	box.get_parent().remove_child(box)
	
	if pick_box:
		_box_holder.add_child(box)
		box.set_owner(_box_holder)
		box.highlight = false
	else:
		space.add_child(box)
		box.set_owner(space)
		space.highlight = false


func _move_back(position):
	var distance = translation.distance_to(position)
	_tween.interpolate_property(self, "translation", null, position, distance / PICK_SPEED)
	_tween.start()


func move_to(position, angle):
	var distance = translation.distance_to(position)
	var rot_distance = abs(rotation_degrees.y - angle)
	
	_tween.interpolate_property(self, "translation", null, position, distance / TRAVEL_SPEED)
	_tween.interpolate_property(self, "rotation_degrees:y", null, angle, rot_distance / ROTATE_SPEED)
	_tween.start()
