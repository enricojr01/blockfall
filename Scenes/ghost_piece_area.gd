extends TileMapLayer


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