extends Button

class_name MouseFilter

@export var image: Polygon2D

func _ready():
	# Get the child node (the image)
	var image_node = image # Adjust if the node is named differently
	
	# Set the mouse_filter to MOUSE_FILTER_IGNORE
	image_node.mouse_filter = MOUSE_FILTER_IGNORE
