extends Node2D

var PieceToIconMapping: Dictionary = {
	"J": Vector2i(4, 2),
	"I": Vector2i(5, 2),
	"S": Vector2i(6, 2),
	"O": Vector2i(0, 3),
	"Z": Vector2i(1, 3),
	"L": Vector2i(2, 3),
	"T": Vector2i(3, 3)
}
# Just increment y value for every new cell
var START_POS: Vector2i = Vector2i(1, 1)

# Top of the queue should be the next piece
# Since we are using .pop_back() and .push_back()
# The queue needs to be reversed
var Queue: Array[BlockBase] = []

@export var Display: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	clear_display()
	draw_display()

func set_queue(queue: Array):
	Queue = queue.duplicate()
	Queue.reverse()

func clear_display() -> void:
	for idx in range(7):
		var target: Vector2i = Vector2i(1, START_POS.y + idx)
		Display.erase_cell(target)

func draw_display() -> void:
	var pos = START_POS
	for item: BlockBase in Queue:
		var atlas_coords = PieceToIconMapping.get(item.type)
		Display.set_cell(pos, 0, atlas_coords)
		pos += Vector2i(0, 1)

