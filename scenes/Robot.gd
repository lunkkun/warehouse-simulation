extends KinematicBody


signal box_picked
signal box_placed
signal approached

const APPROACH_DISTANCE = 1.5
const PICK_DISTANCE = 0.74
const PICK_HEIGHT = 0.25
const TRAVEL_SPEED = 4.0
const ROTATE_SPEED = 180.0
const ARM_SPEED = 2.0
const PICK_SPEED = 2.0

var lane = null

onready var _arm = $Arm
onready var _box_holder = $Arm/BoxHolder
onready var _tween = $Tween
onready var _arm_tween = $Arm/Tween


func pick_box(space: Area, via = []):
	_pick_or_place_box(space, via, true)


func place_box(space: Area, via = []):
	_pick_or_place_box(space, via)


func _pick_or_place_box(space: Area, via = [], pick_box = false):
	_move_to_approach_position(space, via)
	
	yield(self, "approached")
	
	var approach_position = translation
	_move_to_pick_position(space)
	
	yield(_tween, "tween_all_completed")
	
	_pick_or_place(space, pick_box)
	move_to(approach_position, true)
	
	yield(_tween, "tween_all_completed")
	
	# fix floating point errors
	transform = transform.orthonormalized()
	
	if pick_box:
		emit_signal("box_picked")
	else:
		emit_signal("box_placed")


func _move_to_approach_position(space: Area, via = []):
	var space_position = space.get_parent().to_global(space.translation)
	var approach_position = space.get_parent().to_global(space.translation - space.approach_dir * APPROACH_DISTANCE)
	var approach_dir = (space_position - approach_position).normalized()

	var forward = -transform.basis.z.normalized()
	var rotation_angle = (forward).angle_to(approach_dir)
	if forward.rotated(Vector3.UP, rotation_angle).dot(approach_dir) < 0:
		rotation_angle = -rotation_angle
	var rotation_y = round(rotation_degrees.y + rotation_angle * 180 / PI)
	
	var arm_height = approach_position.y + PICK_HEIGHT
	
	move_arm(rotation_y, arm_height)
	
	for nav_point in via:
		move_to(nav_point.global_transform.origin)
		yield(_tween, "tween_all_completed")
	
	approach_position.y = 0
	move_to(approach_position)
	
	yield(_tween, "tween_all_completed")
	if (_arm_tween.is_active()):
		yield(_arm_tween, "tween_all_completed")
	
	emit_signal("approached")


func _move_to_pick_position(space):
	var pick_position = space.get_parent().to_global(space.translation - space.approach_dir * PICK_DISTANCE)
	pick_position.y = 0
	move_to(pick_position, true)


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


func move_to(position: Vector3, picking = false):
	var distance = translation.distance_to(position)
	var speed = PICK_SPEED if picking else TRAVEL_SPEED
	
	_tween.interpolate_property(self, "translation", null, position, distance / speed)
	_tween.start()


func move_arm(angle: float, height: float):
	var rot_distance = abs(rotation_degrees.y - angle)
	var arm_distance = abs(_arm.translation.y - height)
	
	_arm_tween.interpolate_property(self, "rotation_degrees:y", null, angle, rot_distance / ROTATE_SPEED)
	_arm_tween.interpolate_property(_arm, "translation:y", null, height, arm_distance / ARM_SPEED)
	_arm_tween.start()
