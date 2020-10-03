extends TileMap

onready var path = get_node("../Path2D")
onready var ghost = get_node("../Ghost")
var tracks_placed = []
var last_placed
var left_pressed = false
var right_pressed = false

class Track:
	var point: int
	var pos: Vector2

func _ready():
	# add starting point
	var tile = Vector2(0,0)
	place(tile, true)


func is_valid_placement(tile):
	if self.get_cellv(tile) == -1:
		var distance_placed = tile.distance_to(tracks_placed.back().pos)
		if distance_placed == 1:
			return true
	return false
	

func place(tile, skip_check = false):
	if skip_check or is_valid_placement(tile):
		var center_of_tile = self.map_to_world(tile)
		self.set_cellv(tile, 1)
		path.curve.add_point(center_of_tile)		
		var track = Track.new()
		track.point = path.curve.get_point_count() - 1
		track.pos = tile
		tracks_placed.push_back(track)

func remove(tile):
	var last = tracks_placed.back()
	if tile == last.pos:
		self.set_cellv(tile, -1)
		path.curve.remove_point(last.point)
		tracks_placed.pop_back()


func _input(event):
	if event.is_action_pressed("click"):
		left_pressed = true
		var mouse_pos = get_global_mouse_position()
		var tile = world_to_map(mouse_pos)
		place(tile)
	elif event.is_action_released("click"):
		left_pressed = false
	elif event.is_action_pressed("right_click"):
		right_pressed = true
		var mouse_pos = get_global_mouse_position()
		var tile = world_to_map(mouse_pos)
		remove(tile)
	elif event.is_action_released("right_click"):
		right_pressed = false
	elif event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var tile = world_to_map(mouse_pos)
		var center_of_tile = self.map_to_world(tile)
		if left_pressed:
			ghost.visible = false
			place(tile)
		elif right_pressed:
			ghost.visible = false
			remove(tile)
		else:
			if is_valid_placement(tile):
				ghost.modulate.a = 0.9
			else:
				ghost.modulate.a = 0.3
			ghost.position = center_of_tile
			ghost.visible = true

		
