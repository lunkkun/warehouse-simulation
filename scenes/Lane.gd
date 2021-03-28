extends Area


onready var _nav_points = $NavPoints.get_children()


func get_closest_nav_point(position: Vector3):
	var closest = null
	var smallest_dist = null
	
	for nav_point in _nav_points:
		var distance = position.distance_to(nav_point.global_transform.origin)
		if not closest or distance < smallest_dist:
			closest = nav_point
			smallest_dist = distance
	
	return closest
