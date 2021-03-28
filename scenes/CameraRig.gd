extends Spatial


export(NodePath) var follow

onready var _object_to_follow = get_node(follow) if follow else null
onready var _camera = $Camera


func _physics_process(delta):
	if (follow):
		var target = _object_to_follow.global_transform.origin
		target.y += 1
		_camera.look_at(target, Vector3.UP)
