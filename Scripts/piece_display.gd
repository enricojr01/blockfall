class_name PieceDisplay extends Node2D

var PieceToIconMapping: Dictionary = {
	"J": Vector2i(4, 2),
	"I": Vector2i(5, 2),
	"S": Vector2i(6, 2),
	"O": Vector2i(0, 3),
	"Z": Vector2i(1, 3),
	"L": Vector2i(2, 3),
	"T": Vector2i(3, 3)
}
var TargetCell: Vector2i = Vector2i(1, 1)
var AtlasCoords: Vector2i = Vector2i.ZERO
@export var Display: TileMapLayer


func set_icon(icon: String):
	var display_icon = PieceToIconMapping.get(icon)
	if display_icon == null:
		return
	else:
		Display.set_cell(TargetCell, 0, display_icon)

