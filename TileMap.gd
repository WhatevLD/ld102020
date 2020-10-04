extends TileMap

onready var path = get_node("../YSort/Path2D")
onready var train = get_node("../YSort/Path2D/PathFollow2D/Train")
onready var ghost = get_node("../Ghost")
onready var camera = get_node("../Camera2D")

var tracks_placed = []
var last_mouse
var place_mode = false
var remove_mode = false
var left_pressed = false
var right_pressed = false

const GRID_SIZE = 32

class Track:
	var point: int
	var pos: Vector2

func _ready():
	# add starting point
	var tile = Vector2(1,1)
	place(tile, true)
	train.initial_resources()


func is_valid_placement(tile):
	var pos = self.map_to_world(tile)
	if self.get_cellv(tile) == -1:
		var distance_placed = tile.distance_to(tracks_placed.back().pos)
		if distance_placed == 1:
			var resources = get_tree().get_nodes_in_group("Resources")
			for node in resources:
				var distance = pos.distance_to(node.position)
				if distance < GRID_SIZE: 
					return false
			return true
	return false
	

func place(tile, skip_check = false):
	if skip_check or is_valid_placement(tile):
		if !skip_check:
			place_mode = true
		if skip_check or train.can_build():
			var center_of_tile = self.map_to_world(tile)
			self.set_cellv(tile, 0)
			path.curve.add_point(center_of_tile)		
			var track = Track.new()
			track.point = path.curve.get_point_count() - 1
			track.pos = tile
			tracks_placed.push_back(track)
			train.build()

func remove(tile):
	var last = tracks_placed.back()
	if tile == last.pos and tracks_placed.size() > 1:
		remove_mode = true
		self.set_cellv(tile, -1)
		path.curve.remove_point(last.point)
		tracks_placed.pop_back()
		train.unbuild()


func _input(event):
	if event.is_action_pressed("click"):
		left_pressed = true
		var mouse_pos = get_global_mouse_position()
		var tile = world_to_map(mouse_pos)
		last_mouse = mouse_pos
		place(tile)
	elif event.is_action_released("click"):
		left_pressed = false
		place_mode = false
	elif event.is_action_pressed("right_click"):
		right_pressed = true
		var mouse_pos = get_global_mouse_position()
		var tile = world_to_map(mouse_pos)
		remove(tile)
	elif event.is_action_released("right_click"):
		right_pressed = false
		remove_mode = false
	elif event.is_action_pressed("zoom_in"):
		if camera.zoom.x > 1:
			camera.zoom.x -= 0.1
			camera.zoom.y -= 0.1
	elif event.is_action_pressed("zoom_out"):
		if camera.zoom.x < 2:
			camera.zoom.x += 0.1
			camera.zoom.y += 0.1	
	elif event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var tile = world_to_map(mouse_pos)
		var center_of_tile = self.map_to_world(tile)
		if left_pressed:
			ghost.visible = false
			if place_mode:
				place(tile)
			else:
				camera.position += last_mouse - mouse_pos
		elif right_pressed:
			ghost.visible = false
			if remove_mode:
				remove(tile)
		else:
			if is_valid_placement(tile):
				ghost.modulate.a = 0.9
			else:
				ghost.modulate.a = 0.3
			ghost.position = center_of_tile
			ghost.visible = true

		
