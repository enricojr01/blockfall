extends TileMapLayer

@onready var BorderArea: TileMapLayer = $"./HiddenBorders"


# returns true if any piece of the block is outside the bounds area AND
# 	if the corresponding cells in the play area are empty.
# returns false otherwise
func check_valid(piece: BlockBase) -> bool:
	var border_rect: Rect2i = BorderArea.get_used_rect()

	for offset: Vector2i in piece.get_current_rotation():
		var final = piece.tilemap_position + offset
		if !(border_rect.has_point(final)):
			return false
		if self.get_cell_tile_data(final):
			return false

	return true


# returns true if the entire piece is outside the bounds area
# false otherwise. 
func check_entire_valid(piece: BlockBase) -> bool:
	var border_rect: Rect2i = BorderArea.get_used_rect()

	for offset: Vector2i in piece.get_current_rotation():
		var final = piece.tilemap_position + offset
		if border_rect.has_point(final):
			return false
	
	return true


# Draws `piece` on `area` at the given position
func piece_draw(piece: BlockBase) -> void:
	for pos: Vector2i in piece.get_current_rotation():
		var final: Vector2i = piece.tilemap_position + pos
		self.set_cell(final, 0, piece.atlas_coord)


# Clears `piece` from the given `area`
func piece_clear(piece: BlockBase):
	for pos: Vector2i in piece.get_current_rotation():
		var final: Vector2i = piece.tilemap_position + pos
		self.erase_cell(final)
