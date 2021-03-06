extends PanelContainer

var icon_ext := ""

func init(icon_url:String,title:String,description:String,difficulty:String="",date:String=""):
	if icon_url != "":
		icon_ext = icon_url.get_extension()
		var http_error = $HTTPRequest.request(icon_url)
		if http_error != OK:
			print("http err",http_error)
	var title_node:=$HBoxContainer/VBoxContainer/HBoxContainer/title
	title_node.text=title
	match difficulty:
		"Bronze":
			title_node.set("custom_colors/font_color",Color.chocolate)
		"Silver":
			title_node.set("custom_colors/font_color",Color.silver)
		"Gold":
			title_node.set("custom_colors/font_color",Color.gold)
		"Platinum":
			title_node.set("custom_colors/font_color",Color.powderblue)
	$HBoxContainer/VBoxContainer/HBoxContainer/subtitle.visible= date!=""
	$HBoxContainer/VBoxContainer/HBoxContainer/subtitle.text="(Unlocked %s)" % date
	$HBoxContainer/VBoxContainer/description.text=description


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = OK
	if icon_ext == "jpg":
		image_error = image.load_jpg_from_buffer(body)
	elif icon_ext == "png":
		image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("img err")
	

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Assign to the child TextureRect node
	$HBoxContainer/icon.texture = texture
