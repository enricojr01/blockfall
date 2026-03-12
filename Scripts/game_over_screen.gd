extends PanelContainer

var Score: int = 0

func set_score(score: int):
	Score = score
	$"VBoxContainer/ScoreLabel".text = "You cleared %s lines!" % Score