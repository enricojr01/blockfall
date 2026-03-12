extends Node2D

var BlockData = preload("res://Scripts/block_data.gd")
var Base = preload("res://Scenes/BlockBase.tscn")
var Queue: Array[BlockBase] = []
var NextPiece: BlockBase 
var CurrentPiece: BlockBase
var GhostPiece: BlockBase
var HoldPiece: BlockBase
var LinesCleared: int = 0

var IsGameOver: bool = false
var IsHoldLocked: bool = false
var IsPaused: bool = false

@export var PlayArea: TileMapLayer
@export var BorderArea: TileMapLayer
@export var GhostPieceArea: TileMapLayer
@export var DeadZone: TileMapLayer
@export var MoveLockoutTimer: Timer
@export var FallTimer: Timer
@export var GameTimer: Timer

@onready var HoldPieceDisplay: Node2D = $"../GameBoard/Decorative/PieceDisplay"
@onready var QueueDisplay: Node2D = $"../GameBoard/Decorative/QueueDisplay"
@onready var LineCounter: Node2D = $"../GameBoard/Decorative/ScoreDisplay"
@onready var TimeDisplay: Node2D = $"../GameBoard/Decorative/TimeDisplay"
@onready var GameOverScreen: Control = $"../CanvasLayer/GameOverScreen"
@onready var PauseScreen: Control = $"../CanvasLayer/PauseScreen"
const SPAWN_POSITION_MAP = Vector2i(4, 2) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_queue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameTimer.is_stopped():
		print("Starting game timer!");
		GameTimer.start()

	if IsGameOver:
		GameOverScreen.set_score(LinesCleared)
		GameOverScreen.visible = true
		return

	if IsPaused:
		return

	if (len(Queue) == 0):
		fill_queue()

	if CurrentPiece == null:
		next_piece()
		next_ghost_piece()
		# check game over here?
		return

	TimeDisplay.set_time(GameTimer.time_left)

	# It's important to clear the piece first before updating its position 
	# otherwise we get "ghosting"
	GhostPieceArea.piece_clear(GhostPiece)
	PlayArea.piece_clear(CurrentPiece)

	if Input.is_action_just_pressed("rotate_cw"):
		rotate_cw(CurrentPiece)

	if Input.is_action_pressed("move_left"):
		if MoveLockoutTimer.is_stopped():
			move(CurrentPiece, Vector2i.LEFT)
			MoveLockoutTimer.start()

	if Input.is_action_pressed("move_right"):
		if MoveLockoutTimer.is_stopped():
			move(CurrentPiece, Vector2i.RIGHT)
			MoveLockoutTimer.start()

	if Input.is_action_pressed("soft_drop"):
		if MoveLockoutTimer.is_stopped():
			move(CurrentPiece, Vector2i.DOWN)
			MoveLockoutTimer.start()
			# I think this might fix the whole not-being-able-to-adjust
			# blocks-that-have-hit-the-bottom-before-they-lock problem
			FallTimer.start()
	
	if Input.is_action_just_pressed("ui_cancel"):
		IsPaused = !IsPaused
		PauseScreen.visible = !PauseScreen.visible
		GameTimer.paused = true
		return

	if Input.is_action_just_pressed("hold_piece"):
		if HoldPiece == null:
			if IsHoldLocked == false:
				HoldPiece = _block_duplicate(CurrentPiece)
				CurrentPiece = null
				GhostPiece = null
				IsHoldLocked = true
				print("Hold piece set to: ", HoldPiece)
				HoldPieceDisplay.set_icon(HoldPiece.type)
				return
		if HoldPiece != null:
			if IsHoldLocked == true:
				print("Hold is locked, returning.")
				return
			else:
				print("Releasing held piece, swapping with current.")
				var temp = _block_duplicate(CurrentPiece)
				CurrentPiece = HoldPiece
				HoldPiece = temp
				GhostPiece = _block_duplicate(CurrentPiece)
				GhostPiece.atlas_coord = BlockData.atlas_coords["G"]
				IsHoldLocked = true
				HoldPieceDisplay.set_icon(HoldPiece.type)
				return

	if Input.is_action_just_pressed("hard_drop"):
		while true:
			var res = move(CurrentPiece, Vector2i.DOWN)
			if res == false:
				lock(CurrentPiece)
				LinesCleared += PlayArea.clear_lines()
				if PlayArea.check_deadzone(CurrentPiece):
					IsGameOver = true
					return
				CurrentPiece = null
				GhostPiece = null
				IsHoldLocked = false
				return

	# This bit of code handles the block automatically falling
	# at a rate of 1 unit per second.
	if FallTimer.is_stopped():
		var res = move(CurrentPiece, Vector2i.DOWN)
		if res == false:
			lock(CurrentPiece)
			# check game over here
			if PlayArea.check_deadzone(CurrentPiece):
				IsGameOver = true
				return
			LinesCleared += PlayArea.clear_lines()
			CurrentPiece = null
			GhostPiece = null
			IsHoldLocked = false
			return
		FallTimer.start()

	LineCounter.set_score(LinesCleared)
	handle_ghost_piece(GhostPiece, CurrentPiece)
	PlayArea.piece_draw(CurrentPiece)
	GhostPieceArea.piece_draw(GhostPiece)


# Updates the position of the CurrentPiece, moving it in a given direction.
# This function will also handle "constraining" the piece to the PlayArea.
func move(piece: BlockBase, direction: Vector2i) -> bool:
	piece.tilemap_position += direction

	if PlayArea.check_valid(piece) != true:
		piece.tilemap_position -= direction
		return false

	return true


func rotate_cw(piece: BlockBase):
	piece.rotate_cw()
	if PlayArea.check_valid(piece) == false:
		if attempt_wallkick(piece) == false:
			piece.rotate_ccw()


func rotate_ccw(piece: BlockBase):
	piece.rotate_ccw()
	if PlayArea.check_valid(piece) == false:
		if attempt_wallkick(piece) == false:
			piece.rotate_ccw()


func handle_ghost_piece(ghost_piece: BlockBase, current_piece: BlockBase):
	# The ghost piece is special, since it's not controlled by the player
	# and is a sort of "targeting reticle" that the player uses to guide
	# their movements.
	# As such it needs to basically move and rotate in tandem with the 
	# player-controlled piece and then be placed as far down as possible.
	ghost_piece.tilemap_position = current_piece.tilemap_position
	ghost_piece.rotation_idx = current_piece.rotation_idx

	while true:
		var res = move(ghost_piece, Vector2i.DOWN)
		if res == false:
			break


# Locks the piece at its current position by permanently drawing it to the
# PlayArea, and immediately clearing the CurrentPiece
func lock(piece: BlockBase):
	for offset: Vector2i in piece.get_current_rotation():
		var final: Vector2i = piece.tilemap_position + offset
		PlayArea.set_cell(final, 0, piece.atlas_coord)


func attempt_wallkick(piece: BlockBase) -> bool:
	# The simplest wallkick algorithm involves testing if the block
	# can be placed one cell to left, or one cell to the right

	# First, we check the left side
	move(piece, Vector2i.LEFT)
	if PlayArea.check_valid(piece):
		# true - wallkick success!
		return true
	else:
		# move it back in case its not valid
		move(piece, Vector2i.RIGHT)

	# Then we check the right side
	move(piece, Vector2i.RIGHT)	
	if PlayArea.check_valid(piece):
		return true
	else:
		# move it back if its not a valid position
		move(piece, Vector2i.LEFT)

	# false - wallkick fail!	
	return false


# Implements a simple 7-bag randomizer.
func fill_queue() -> void:
	var keys = BlockData.piece_definitions.keys()
	keys.shuffle()
	for item in keys:
		var piece_rotation: Array = BlockData.piece_definitions[item]
		var atlas_coord: Vector2i = BlockData.atlas_coords[item]
		var block: BlockBase = _block_factory(
			item, 
			piece_rotation, 
			atlas_coord, 
			SPAWN_POSITION_MAP
		)
		Queue.push_back(block)

	QueueDisplay.set_queue(Queue)


# Implements a simple 7-bag randomizer.
func next_piece() -> void:
	# Grab the piece off the top of the queue
	CurrentPiece = Queue.pop_back()

	# Set the spawn point for both to the same place
	CurrentPiece.tilemap_position = SPAWN_POSITION_MAP

	# Update the queue display.
	QueueDisplay.set_queue(Queue)


func next_ghost_piece() -> void:
	# The duplicate() method doesn't seem to create a "deep copy" of the
	# other object. I have to manually assign the rotations / atlas coordinates.
	GhostPiece = _block_duplicate(CurrentPiece)
	GhostPiece.atlas_coord = BlockData.atlas_coords["G"]

func reset_board():
	PlayArea.clear()	
	GhostPieceArea.clear()
	CurrentPiece = null
	Queue = []
	GhostPiece = null
	IsGameOver = false
	LinesCleared = 0
	GameOverScreen.visible = false


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


func _block_duplicate(block: BlockBase):
	var new_block_rotations: Array = BlockData.piece_definitions[block.type]
	var new_block_atlas_coords: Vector2i = BlockData.atlas_coords[block.type]
	var new_block = _block_factory(
		block.type, 
		new_block_rotations, 
		new_block_atlas_coords,
		SPAWN_POSITION_MAP
	)
	return new_block


func _on_restart_button_pressed() -> void:
	reset_board()
	IsPaused = false
	PauseScreen.visible = false
	GameTimer.paused = false
	GameTimer.stop()


func _on_game_timer_timeout() -> void:
	IsGameOver = true


func _on_resume_button_pressed() -> void:
	IsPaused = false
	PauseScreen.visible = false
	GameTimer.paused = false


func _on_back_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
