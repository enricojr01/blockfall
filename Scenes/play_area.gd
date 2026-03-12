extends TileMapLayer


@onready var BoundsArea = $"./HiddenBounds"
@onready var Deadzone = $"./Deadzone"


# Draws `piece` on `area` at the given position
func piece_draw(piece: BlockBase) -> void:
	var rot: Array = piece.get_current_rotation()
	for pos: Vector2i in rot:
		var final: Vector2i = piece.tilemap_position + pos
		self.set_cell(final, 0, piece.atlas_coord)


# Clears `piece` from the given `area`
func piece_clear(piece: BlockBase):
	var rot: Array = piece.get_current_rotation()
	for pos: Vector2i in rot:
		var final: Vector2i = piece.tilemap_position + pos
		self.erase_cell(final)


# Checks if CurrentPiecePosition is within the bounds of the play area,
# and not occupied by anything else. It works by checking to see if every cell
# of the current piece is within the BorderArea's rect2i, and then checking
# if the corresponding cell in the PlayArea itself is occupied.
func check_valid(piece: BlockBase) -> bool:
	var border_rect: Rect2i = BoundsArea.get_used_rect()

	for offset: Vector2i in piece.get_current_rotation():
		var final = piece.tilemap_position + offset
		if !(border_rect.has_point(final)):
			# false - `final` is not within the bounds of the border rect
			return false
		if self.get_cell_tile_data(final):
			# false - `final` is already occupied by another tile
			return false

	# true - the entire piece is occupying a valid position on the board
	# one that is not occupied by anything else and is within the bounds of
	# the rect provided by BoundsArea.
	return true


func clear_lines() -> int:
	# So TileMapLayers aren't really designed to be used for games that require
	# a fixed grid like Tetris, they don't have bounds that allow them to be
	# iterated over the way you would with a 2d array.

	# .get_used_rect() returns a rect encompassing only the area that has
	# cells in it, and it isn't always as wide as the actual play area so
	# its not suitable to use in this scenario. 

	# The workaround I've come up with is to use an invisible TileMapLayer 
	# filled with a random block and use that as the basis for the iteration. 
	# It's the same layer that I'm using for bounds checking so its exactly the 
	# same size as the play area.
	
	# The idea is that I will iterate over every row in this hidden area
	# and use the coordinates in those to check if the corresponding cell in
	# the main Play area is occupied. That information is then used to 
	# drive the mechanism that clears the rows as well.

	# The other big "innovation" I've made is to take care to draw all the
	# assets in Quadrant 4 of the grid. This way 0, 0 is in the top-left corner
	# just as you'd expect, and I don't need to do any futzing with coordinate
	# transforms.
	var lines_cleared = 0
	var compare = BoundsArea.get_used_rect()
	print(compare.size)
	for y in range(compare.size.y):
		if is_row_full(y):
			print("Row %s is full." % y)
			clear_row(y)
			lines_cleared += 1

	return lines_cleared


func is_row_full(row_idx: int):
	var rect = BoundsArea.get_used_rect()
	for x in range(rect.size.x):
		var pos = Vector2i(x, row_idx)
		var tile_data = self.get_cell_tile_data(pos)
		if tile_data == null:
			return false
	
	return true


func clear_row(row_idx: int):
	var rect = BoundsArea.get_used_rect()

	# erase every cell in the target row
	for x in range(rect.size.x):
		var pos = Vector2i(x, row_idx)
		self.erase_cell(pos)

	# move every row above the cleared one down one space, one cell
	# at a time
	while row_idx != 0:
		for x in range(rect.size.x):
			var cell_above_pos = Vector2i(x, row_idx - 1)
			var cell_above_atlas = self.get_cell_atlas_coords(cell_above_pos)
			var cell_above_source_id = self.get_cell_source_id(cell_above_pos)

			self.set_cell(
				Vector2i(x, row_idx), 
				cell_above_source_id, 
				cell_above_atlas
			)
		row_idx -= 1


func check_deadzone(piece: BlockBase) -> bool:
	var rect: Rect2i = Deadzone.get_used_rect()

	for offset: Vector2i in piece.get_current_rotation():
		var final = piece.tilemap_position + offset
		if (rect.has_point(final)):
			return true
	
	return false
