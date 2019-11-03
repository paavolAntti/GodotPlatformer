extends Camera2D

const camera_speed = 200

func _process(delta):
	self.position.x += camera_speed*delta
