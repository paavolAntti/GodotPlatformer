extends TileMap


func _ready():
	set_process(true)


func _process(delta):
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var mousePos = get_viewport().get_mouse_position()
		var loc = world_to_map(mousePos)
		var cell = get_cell(loc.x, loc.y)
		if(cell != -1):
			print(self.tile_set.tile_get_name(cell))
		else:
			set_cell(loc.x, loc.y, 1)
