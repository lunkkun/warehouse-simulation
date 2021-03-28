extends Area


export var highlight = false setget set_highlight

var box = null setget set_box, get_box
var approach_dir = Vector3.FORWARD

onready var _outline = $MeshInstance


func set_box(_box):
	box = _box


func get_box():
	return box


func set_highlight(value):
	highlight = value
	
	if highlight:
		_outline.show()
	else:
		_outline.hide()


func _on_ShelfSpace_body_entered(body):
	set_box(body)


func _on_ShelfSpace_body_exited(body):
	if box == body:
		set_box(null)
