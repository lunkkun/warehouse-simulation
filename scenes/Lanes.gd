extends Spatial


signal lane_entered(lane)

onready var _lanes = get_children()


func _ready():
	for lane in _lanes:
		lane.connect("body_entered", self, "_on_Lane_body_entered", [lane])


func get_lane(object):
	for lane in _lanes:
		if object is Area and lane.overlaps_area(object):
			return lane
		elif object is PhysicsBody and lane.overlaps_body(object):
			return lane


func _on_Lane_body_entered(body, lane):
	if body.is_in_group("robots"):
		emit_signal("lane_entered", lane)
