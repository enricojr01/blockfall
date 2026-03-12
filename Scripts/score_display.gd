extends Node2D

# TODO: Figure out a nicer way to do this.
var NumberMapping: Dictionary = {
	"0": Vector2i(4, 3),
	"1": Vector2i(5, 3),
	"2": Vector2i(6, 3),
	"3": Vector2i(0, 4),
	"4": Vector2i(1, 4),
	"5": Vector2i(2, 4),
	"6": Vector2i(3, 4),
	"7": Vector2i(4, 4),
	"8": Vector2i(5, 4),
	"9": Vector2i(6, 4),
}
@export var Display: TileMapLayer
# for now this will be 4 cells large.
var DisplayCells: Array = [
	Vector2i(1, 1), 
	Vector2i(2, 1), 
	Vector2i(3, 1), 
	Vector2i(4, 1)
]
var Score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	clear_display()
	draw_display(Score)

func set_score(num: int):
	Score = num

func clear_display():
	for x: int in range(DisplayCells.size()):
		Display.erase_cell(DisplayCells[x])


func draw_display(number: int):
	if number > 9999:
		number = 9999

	var num: String = str(number).pad_zeros(4)
	var icons: Array = []

	for digit: String in num:
		var i: Vector2i = NumberMapping[digit]	
		icons.push_back(i)

	for x in range(DisplayCells.size()):
		var target = DisplayCells[x]
		var digit = icons[x]
		Display.set_cell(target, 0, digit)
