extends Node2D

export var resources = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func can_build():
	if resources.has("wood") and resources.has("iron"):
		if resources["wood"] >= 10 and resources["iron"] >= 10:
			return true
	return false

func build():
	if resources.has("wood") and resources.has("iron"):
		resources["wood"] -= 10
		resources["iron"] -= 10
		
func unbuild():
	if resources.has("wood") and resources.has("iron"):
		resources["wood"] += 5
		resources["iron"] += 5
		
func initial_resources():
	resources["wood"] = 100
	resources["iron"] = 100

func get_resources(area):
	var resource_name = area.get_parent().resource_name
	var num_resources = area.get_parent().num_resources
	area.get_parent().num_resources = 0
	
	if !resources.has(resource_name):
		resources[resource_name] = num_resources
	else:		
		resources[resource_name] += num_resources	

func _on_Area2D_area_entered(area):
	get_resources(area)
	


func _on_Area2D_area_exited(area):
	get_resources(area)
