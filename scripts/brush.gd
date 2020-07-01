extends Control

var brush_size = 50
var brush_color = Color.red

var pressed = false
var brushDraw = null
var old_point = Vector2.ZERO

func _draw():
	# draw brush preview
	var bc = Color(0,0,0,.5)
	if bc != null:
		draw_circle_arc(get_global_mouse_position() - self.rect_position, brush_size / 2, 0, 360, bc)
	
func draw_circle_arc( center, radius, angleFrom, angleTo, color ):
	var nbPoints = 32
	var pointsArc = PoolVector2Array()
	
	for i in range(nbPoints+1):
		var anglePoint = angleFrom + i*(angleTo-angleFrom)/nbPoints - 90
		var point = center + Vector2( cos(deg2rad(anglePoint)), sin(deg2rad(anglePoint)) )* radius
		pointsArc.push_back( point )
	
	for indexPoint in range(nbPoints):
		draw_line(pointsArc[indexPoint], pointsArc[indexPoint+1], color)


func _physics_process(_delta):
	if pressed:
		if brushDraw is Line2D:
			var m = get_viewport().get_mouse_position() - self.rect_position
			if abs(old_point.distance_to(m)) > 10:
				brushDraw.add_point(m)
				old_point = m

func _input(event):
	if event is InputEventMouseMotion:
		update()
		return

	if event is InputEventMouseButton:
		if event.button_index in [BUTTON_WHEEL_UP, BUTTON_WHEEL_DOWN]:
			update()
			return

	# start draw on screentouch
	var mPos = get_viewport().get_mouse_position()
	if mPos.x < 0: return
	
	if event is InputEventScreenTouch:
		if event.is_pressed():
			pressed = true
			
			# setting brush
			brushDraw = Line2D.new()
			brushDraw.add_to_group("brush_line")
			brushDraw.joint_mode = Line2D.LINE_JOINT_ROUND
			brushDraw.begin_cap_mode = Line2D.LINE_CAP_ROUND
			brushDraw.end_cap_mode = Line2D.LINE_CAP_ROUND
			#brushDraw.antialiased = true
			
			brushDraw.default_color = Color(randf(), randf(), randf(), 1)
			brushDraw.width = brush_size
			call_deferred("add_child", brushDraw)
			
			var m = get_viewport().get_mouse_position() - self.rect_position
			brushDraw.add_point(m)
			brushDraw.add_point(m + Vector2(1,1))
			old_point = m
			
		else:
			pressed = false

func _on_brush_mouse_entered():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_brush_mouse_exited():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
