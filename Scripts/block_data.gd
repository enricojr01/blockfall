extends Node2D

const piece_definitions: Dictionary[String, Array] = {
	"I": [
		[Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)],
		[Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)],
		[Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
		[Vector2i(-1, -2), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)],
	],
	"J": [
		[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
		[Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(0, 1)],
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, 1)]
	],
	"L": [
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-2, 0)],
		[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-2, 0), Vector2i(-2, 1)],
		[Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)],
	],
	"O": [
		[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(-1, 0)],
	],
	"S": [
		[Vector2i(0, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-2, 0)],
		[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-2, 1)],
		[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1)],
	],
	"T": [
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0)],
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, 0)],
	],
	"Z": [
		[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
		[Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 0), Vector2i(0, 1)],
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1)],
	],
}

# NOTE: The "G" is for "ghost", i.e. ghost piece
const atlas_coords: Dictionary = {
	"I": Vector2i(1, 0),
	"J": Vector2i(0, 0),
	"L": Vector2i(6, 0),
	"O": Vector2i(3, 0),
	"S": Vector2i(2, 0),
	"T": Vector2i(5, 0),
	"Z": Vector2i(4, 0),
	"G": Vector2i(3, 2),
}