extends PanelContainer


func init(rank:int,pseudo:String,score:String):
	if rank==1:
		$cont/HBoxContainer/top.set("custom_colors/font_color",Color.gold)
	elif rank==2:
		$cont/HBoxContainer/top.set("custom_colors/font_color",Color.silver)
	elif rank==3:
		$cont/HBoxContainer/top.set("custom_colors/font_color",Color.chocolate)
	$cont/HBoxContainer/top.text=str(rank)
	$cont/HBoxContainer/pseudo.text=pseudo
	$cont/score.text=score
