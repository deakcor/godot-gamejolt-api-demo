extends Control

#first copy gamejolt_api_v2 folder in an addons folder in your project
# Project/Settings/Plugins -> set gamejolt api active
#Add a node GameJoltAPI or use it with a composition in a singleton(better for a game project)
onready var gj:=$gj
onready var container:=$container
onready var log_text:=$container/cont_log/log_text
onready var score_text:=$container/score/container/score_text
onready var ld_text:=$container/Leaderboard/container/text_ld
onready var welcome_text:=$container/auth/welcome_text
onready var trophies:=$container/trophy/container/trophies
onready var button_trophy:=$container/trophy/container/button_trophy

var username:String
var token:String
var score:=0
var last_score:=0
var trophy:=[]

var wait_update:=false

# The auth file isn't share online because it contains my private key, see script/auth_template.gd
var auth = Auth.new()

func _ready():
	log_text.set_text("")
	#use your private key and game id
	gj.init(auth.private_key,auth.game_id)
	gj.connect("gamejolt_request_completed",self,"_gj_completed")
	
func _gj_completed(type,message,finished):
	log_text.text+="\n"+type+str(message)+"\n"
	if type=="/sessions/open/":
		if message["success"]:
			# You well logged
			$container/auth/noauth.visible=false
			welcome_text.set_text("Welcome, "+gj.get_username())
			gj.fetch_global_scores(8, 405532, 0, null)
			gj.fetch_data("score", false)
			gj.fetch_trophy(null, null)
			score_text.set_text("Loading your score...")
			
	elif type=="/scores/":
		if message["success"]:
			# fetched scores
			var i=0
			ld_text.set_text("")
			print(message["scores"])
			while message["scores"].size()>i:
				ld_text.text+="\n"+str(i+1)+") "+message["scores"][i]["user"]+" : "+message["scores"][i]["score"]
				i+=1
	elif type=='/scores/add/':
		if message["success"]:
			# added scores
			last_score=score
			gj.set_data("score", score, false)
			score_text.set_text("Your score : "+str(score)+"\nSaved!")
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
			gj.fetch_global_scores(8, 405532, 0, null)
		wait_update=false
	elif type=="/data-store/":
		if message["success"]:
			#fetched data
			score=int(message["data"])
			last_score=score
		$container/score/container/Button.disabled=false
		score_text.set_text("Your score : "+str(score))
	elif type=="/data-store/set/":
		if message["success"]:
			#You well stored your data
			pass
	elif type=="/trophies/":
		button_trophy.disabled=false
		trophies.text=""
		if message["success"]:
			#fetched trophies
			for k in message["trophies"]:
				print(k["achieved"])
				if k["achieved"]!="false":
					trophy.append(k["id"])
					trophies.text+=k["title"]+" :UNLOCKED\n"
					if k["id"]=="104280":
						button_trophy.text="Already Unlocked"
						button_trophy.disabled=true
		print(trophy)
		
	print("finished: "+str(finished))

func _on_auto_auth_pressed():
	gj.auto_auth()
	gj.open_session()


func _on_normal_auth_pressed():
	gj.auth_user(username, token)
	gj.open_session()

func _on_auth_name_text_changed(new_text):
	username=new_text


func _on_auth_token_text_changed(new_text):
	token=new_text


func _on_Button_pressed():
	score+=1
	score_text.set_text("Your score : "+str(last_score)+"+"+str(score-last_score)+"\nNot saved")
	if !wait_update:
		wait_update=true
		gj.add_score(str(score)+" times", score, 405532)
		
func _on_button_trophy_pressed():
	gj.set_trophy_achieved(104280)

