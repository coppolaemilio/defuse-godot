tool
extends EditorPlugin

# A class member to hold the dock during the plugin life cycle.
var dock

func _enter_tree():
	# Initialization of the plugin goes here.
	# Load the dock scene and instance it.
	dock = preload("res://addons/defuse/Main.tscn").instance()

	# Add the loaded scene to the bottom panel.
	add_control_to_bottom_panel(dock, 'Defuse')


func _exit_tree():
	pass
