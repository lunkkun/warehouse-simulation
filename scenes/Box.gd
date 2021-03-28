extends RigidBody


var highlight = false setget set_highlight

onready var _outline = $MeshInstance/Outline


func set_highlight(value):
	highlight = value
	
	if highlight:
		_outline.show()
	else:
		_outline.hide()
