extends Control

var unique_code = ""
var export_imagesize = Vector2(1280, 720)

func _ready():
	randomize()
	
	unique_code = str((randi() % 9999999) + 9999999)
	
	# connect tool buttons
	for b in $VBoxContainer.get_children():
		b.get_node("touch").connect("pressed", self, "_buttonClick", [b.get_name()])
	
	# connect return of HTTP
	var _ret = HttpLayer.connect("request_completed", self, "_on_request_completed")

func _buttonClick(_action):
	match _action:
		"btnSave":
			_save()
		
		"btnTrash":
			for b in $"../brush".get_children():
				if b is Line2D:
					b.queue_free()
		
		"btnBrushPlus":
			_brushSize(1)
			
		"btnBrushMinus":
			_brushSize(-1)
		
		_:
			pass
			# no default action
	
func _brushSize(_fator):
	var bs = $"../brush".brush_size
	bs += 5 * _fator
	bs = clamp(bs, 5, 200)
	$"../brush".brush_size = bs

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			_brushSize(1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_brushSize(-1)


func _save():
	
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	
	# get image
	var img = get_viewport().get_texture().get_data()
	img.expand_x2_hq2x()
	img.resize(export_imagesize.x, export_imagesize.y, Image.INTERPOLATE_LANCZOS)
	
	# crop
	var cropped_image = img.get_rect(Rect2($"../brush".rect_position, Vector2(export_imagesize.x - $"../brush".rect_position.x, export_imagesize.y)))
	cropped_image.resize(export_imagesize.x, export_imagesize.y, Image.INTERPOLATE_LANCZOS)
	cropped_image.flip_y()
		
	# save temp
	var fname = str("res://",unique_code,".png")
	cropped_image.save_png(fname)
	var image = File.new()
	image.open(fname, File.READ)
	
	# prepare json to send
	var image64 = {
		"uniquecode" : unique_code,
		"image" : Marshalls.raw_to_base64(image.get_buffer(image.get_len()))
	}
	
	var dir = Directory.new()
	dir.remove(fname)
	
	# send to HTTP
	HttpLayer.request("download.php", image64, "POST", "saveImage")

func _on_request_completed(_return, _code, _route):
	# download image
	if _code == 200 && _route == "saveImage":
		var _ret = OS.shell_open(str(HttpLayer.endpoint_api, "download.php?d=", unique_code))
