extends Control

# First copy gamejolt_api_v2 folder in an addons folder in your project
# Project/Settings/Plugins -> set gamejolt api active
# Add a node GameJoltAPI or use it with a composition in a singleton(better for a game project)
onready var gj:=$gj
onready var container:=$scroll_container/container
onready var log_text:=container.get_node("cont_log/log_text")
onready var score_text:=container.get_node("score/container/HBoxContainer/PanelContainer/VBoxContainer/score_text")
onready var rank_text:=container.get_node("score/container/HBoxContainer/PanelContainer2/VBoxContainer2/rank_text")
onready var score_text_saving:=container.get_node("score/container/score_text_saving")
onready var user_cont:=container.get_node("Leaderboard/container/ScrollContainer/user_cont")
onready var auth_cont:=container.get_node("auth/auth_cont")
onready var welcome_text:=container.get_node("auth/auth_cont/welcome_text")
onready var trophies_container:=container.get_node("trophy/container/ScrollContainer/trophies_container")
onready var button_trophy:=container.get_node("trophy/container/button_trophy")

onready var no_auth_cont:=container.get_node("auth/noauth")
onready var score_button:=container.get_node("score/container/score_button")

var score:=0
var last_score:=0
var trophy:=[]

var wait_update:=false

# The auth file isn't share online because it contains my private key, see script/auth_template.gd
var auth = Auth.new()

func _ready():
	log_text.bbcode_text = ""
	#use your private key and game id from your auth class
	gj.init(auth.private_key,auth.game_id)
	#gj.verbose = true
	gj.connect("gamejolt_request_completed",self,"_gj_completed")
	get_viewport().connect("size_changed",self,"_vp_size_changed")
	
	# if it's editor, auth for debugging
	if OS.has_feature("editor"):
		gj.auth_user(auth.username, auth.token)
		gj.open_session()
		
func _gj_completed(type:String,message:Dictionary):
	log_text.append_bbcode("\n[color=#ffffff]"+type+"[/color]\n"+str(message)+"\n\n")
	if type=="/sessions/open/":
		if message["success"]:
			# You well logged
			no_auth_cont.visible=false
			auth_cont.visible=true
			welcome_text.set_text("Welcome, "+gj.get_username())
			gj.fetch_global_scores(10, 405532, 0)
			gj.fetch_data("score", false)
			gj.fetch_trophy()
			score_text.set_text("Loading your score...")
			rank_text.set_text("Loading your rank...")
	elif type=="/scores/":
		if message["success"]:
			# fetched scores
			var i=0
			for k in user_cont.get_children():
				k.queue_free()
			while message["scores"].size()>i:
				var new_user := preload("res://scene/user.tscn").instance()
				new_user.init(i+1,message["scores"][i]["user"],message["scores"][i]["score"])
				user_cont.add_child(new_user)
				i+=1
	elif type=='/scores/add/':
		if message["success"]:
			# added scores
			last_score=score
			gj.set_data("score", score, false)
			score_text.set_text(str(score))
			score_text_saving.text = "Saved!"
			if score>9 and trophy.find(104281)==-1:
				gj.set_trophy_achieved(104281)
				trophy.append(104281)
			if score>99 and trophy.find(104282)==-1:
				gj.set_trophy_achieved(104282)
				trophy.append(104282)
			if score>999 and trophy.find(104283)==-1:
				gj.set_trophy_achieved(104283)
				trophy.append(104283)
			if score>9999 and trophy.find(104284)==-1:
				gj.set_trophy_achieved(104284)
				trophy.append(104284)
			if score>99999 and trophy.find(104346)==-1:
				gj.set_trophy_achieved(104346)
				trophy.append(104346)
			if score>999999 and trophy.find(104347)==-1:
				gj.set_trophy_achieved(104347)
				trophy.append(104347)
			gj.fetch_global_scores(10, 405532, 0)
		wait_update=false
	elif type=="/data-store/":
		if message["success"]:
			#fetched data
			score=int(message["data"])
			last_score=score
		score_button.disabled=false
		score_text.set_text(str(score))
		gj.fetch_score_rank(last_score,405532)
	elif type=="/data-store/set/":
		if message["success"]:
			gj.fetch_score_rank(last_score,405532)
	elif type=="/scores/get_rank/":
		if message["success"]:
			rank_text.text = str(message.get("rank",0))
	elif type=="/trophies/":
		button_trophy.disabled=false
		for k in trophies_container.get_children():
			k.queue_free()
		if message["success"]:
			#fetched trophies
			for k in message["trophies"]:
				
				var new_trophy := preload("res://scene/trophy.tscn").instance()
				trophies_container.add_child(new_trophy)
				if k["achieved"] is String:
					trophy.append(k["id"])
					if k["id"]=="104280":
						button_trophy.text="Already Unlocked"
						button_trophy.disabled=true
					new_trophy.init(k.get("image_url",""),k.get("title",""),k.get("description",""),k["achieved"])
				else:
					new_trophy.init("","Hidden","Click more to activate")
				

func _on_auto_auth_pressed():
	gj.auto_auth()
	gj.open_session()


func _on_normal_auth_pressed():
	gj.auth_user(auth.username, auth.token)
	gj.open_session()

func _on_auth_name_text_changed(new_text):
	auth.username=new_text


func _on_auth_token_text_changed(new_text):
	auth.token=new_text


func _on_Button_pressed():
	score+=1
	score_text.set_text(str(last_score)+"+"+str(score-last_score))
	score_text_saving.text = "Saving..."
	if !wait_update:
		wait_update=true
		gj.add_score(str(score)+" times", score, 405532)
		
func _on_button_trophy_pressed():
	gj.set_trophy_achieved(104280)

func _vp_size_changed():
	container.columns=3 if OS.window_size.x>OS.window_size.y else 1
