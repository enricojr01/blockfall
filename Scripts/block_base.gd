class_name BlockBase extends Node2D

var rotations: Array
var rotation_idx: int = 0
var atlas_coord: Vector2i = Vector2i.ZERO
var tilemap_position: Vector2i = Vector2i.ZERO
var type: String
@export var canvas: TileMapLayer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start_shape = rotations[rotation_idx];

	for cell: Vector2i in start_shape:
		canvas.set_cell(cell, 0, atlas_coord)

# Rotates piece 90 degrees clockwise.
func rotate_cw():
	rotation_idx = (rotation_idx + 1) % len(rotations)

# Rotates piece 90 degress counterclockwise
func rotate_ccw():
	rotation_idx = (rotation_idx - 1) % len(rotations)

# Utility function that returns the current piece rotation
func get_current_rotation():
	return rotations[rotation_idx]
