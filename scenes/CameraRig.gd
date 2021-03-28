extends Spatial


const CAMERA_SPEED = 4


export(NodePath) var follow

onready var _object_to_follow = get_node(follow) if follow else null
onready var _camera = $Camera
onready var _tween = $Tween


func move_to(position: Vector3):
	var distance = translation.distance_to(position)
	_tween.interpolate_property(self, "translation", null, position, distance / CAMERA_SPEED, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	_tween.start()


func _physics_process(delta):
	if follow:
		var target = _object_to_follow.global_transform.origin
		target.y += 1
		_camera.look_at(target, Vector3.UP)
