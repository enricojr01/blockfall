extends Node2D

var Base = preload("res://Scenes/BlockBase.tscn")
var BlockData = preload("res://Scripts/block_data.gd")

var Tiles: Array = [
	Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3),
	Vector2i(3, 3)
]
var Queue: Array[BlockBase] = []
var Active: Array[BlockBase]

const SPAWN_POINTS: Array = [
	Vector2i(5, 0),
	Vector2i(10, 0),
	Vector2i(15, 0),
	Vector2i(20, 0),
	Vector2i(25, 0),
	Vector2i(30, 0),
	Vector2i(35, 0),
]

var START_POS: Vector2i = Vector2i(0, 0)
var END_POS: Vector2i = Vector2i(39, 0)
var MAX_PIECES: int = 5 

@export var DrawArea: TileMapLayer
@export var MoveTimer: Timer
@export var SpawnTimer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_queue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# at regular intervals, spawn a random piece from tiles at any point
	# between START_POS and END_POS, and let it fall past the bottom of the 
	# screen
	if Queue.size() == 0:
		fill_queue()

	for x in range(Queue.size()):
		if SpawnTimer.is_stopped():
			var piece = Queue.pop_back()
			Active.push_back(piece)
			SpawnTimer.start()

	if MoveTimer.is_stopped():
		for p in Active:
			DrawArea.piece_clear(p)
			move(p, Vector2i.DOWN)
			DrawArea.piece_draw(p)

		MoveTimer.start()

	for p in Active:
		if DrawArea.check_entire_valid(p):
			print("Clearing piece %s" % p)
			DrawArea.piece_clear(p)

func move(piece: BlockBase, direction: Vector2i) -> bool:
	piece.tilemap_position += direction
	return true


# Handles the instantiation of BlockBase and its configuration.
func _block_factory(
	type: String, 
	rotations: Array, 
	atlas_coord: Vector2i,
	spawn_pos: Vector2i
) -> BlockBase:
	# TODO: is there no way to define a constructor?
	var block = Base.instantiate()
	block.rotations = rotations
	block.atlas_coord = atlas_coord
	block.type = type
	block.tilemap_position = spawn_pos
	return block


func _block_duplicate(block: BlockBase, pos: Vector2i):
	var new_block_rotations: Array = BlockData.piece_definitions[block.type]
	var new_block_atlas_coords: Vector2i = BlockData.atlas_coords[block.type]
	var new_block = _block_factory(
		block.type, 
		new_block_rotations, 
		new_block_atlas_coords,
		pos
	)
	return new_block


func fill_queue() -> void:
	var keys = BlockData.piece_definitions.keys()
	keys.shuffle()
	var spawns = SPAWN_POINTS.duplicate_deep()
	spawns.shuffle()

	for item in keys:
		if Queue.size() <= MAX_PIECES:
			var piece_rotation: Array = BlockData.piece_definitions[item]
			var atlas_coord: Vector2i = BlockData.atlas_coords[item]
			var pos = spawns.pop_back()
			var block: BlockBase = _block_factory(
				item, 
				piece_rotation, 
				atlas_coord,
				pos
			)
			Queue.push_back(block)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Board.tscn")