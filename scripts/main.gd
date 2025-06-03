extends Node

@export var square_scene : PackedScene
@export var arrow_scene : PackedScene
@export var grid_side : int = 8
@export var ckeck_skin : bool
@onready var scene : Node2D = get_node("scene")
@onready var squares_parent : Node2D = scene.get_node("squares")
@onready var knight : Node2D = scene.get_node("knight")
@onready var arrows : Node2D = scene.get_node("arrows")
@onready var window : Window = get_window()
var knight_mouves : Dictionary = {
			"u_l" = Vector2i(-1,-2),
			"u_r" = Vector2i(1,-2),
			"r_u" = Vector2i(2,-1),
			"r_d" = Vector2i(2,1),
			"d_r" = Vector2i(1,2),
			"d_l" = Vector2i(-1,2),
			"l_d" = Vector2i(-2,1),
			"l_u" = Vector2i(-2,-1)
		}
var knight_position : Vector2i = Vector2i.ZERO
var square_side_length : int = 0
var knight_placed : bool = false
var grid : Array = []
var actions : Array = []
var canceled_actions : Array = []
var actual_arrow : Node2D = null
var start_knight_position : Vector2i
var start_mouse_position : Vector2 = Vector2.ZERO
var is_right_click_pressed : bool = false

func _ready() -> void:
	init()
	print("ta mere")

func _process(delta: float) -> void:
	knight.scale = Vector2(1,1) * 0.9 * square_side_length
	var mouse_position : Vector2i = (scene.get_local_mouse_position()-squares_parent.position)/square_side_length
	if not knight_placed:
		knight.get_node("form/arrows").hide()
		knight.position = scene.get_local_mouse_position()
		if (
				knight.position.x > squares_parent.position.x and
				knight.position.x < squares_parent.position.x + grid_side * square_side_length and
				knight.position.y > squares_parent.position.y and
				knight.position.y < squares_parent.position.y + grid_side * square_side_length
			):
			if Input.is_action_just_pressed("click"):
				knight_placed = true
				knight_position = mouse_position
				start_knight_position = knight_position
				knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
				change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, Color.RED)
				grid[knight_position.x + knight_position.y*grid_side] = false
	else :
		knight.get_node("form/arrows").show()
		
		var possibilities : Array = []
		for mouve in knight_mouves:
			var possible_position : Vector2i = knight_position + knight_mouves[mouve]
			if possible_position.x >= 0 and possible_position.x < grid_side:
				if possible_position.y >= 0 and possible_position.y < grid_side:
					if grid[possible_position.x + possible_position.y*grid_side]:
						possibilities.append(mouve)
		
		for arrow in knight.get_node("form/arrows").get_children():
			if possibilities.find(arrow.name) == -1:
				arrow.hide()
			else:
				arrow.show()
		
		if Input.is_action_just_pressed("click"):
			if mouse_position.x >= 0 and mouse_position.x < grid_side:
				if mouse_position.y >= 0 and mouse_position.y < grid_side:
					for mouve in possibilities:
						if mouse_position == knight_position + knight_mouves[mouve]:
							knight_position = mouse_position
							knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
							grid[mouse_position.x + mouse_position.y*grid_side] = false
							change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, Color.RED)
							actions.append(mouve)
							canceled_actions = []
							print(canceled_actions)
							if grid.find(true) == -1:
								print([start_knight_position, actions])
		
		if Input.is_action_just_pressed("right click"):
			actual_arrow = arrow_scene.instantiate()
			actual_arrow.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(mouse_position) * square_side_length
			arrows.add_child(actual_arrow)
			start_mouse_position = scene.get_local_mouse_position()
			actual_arrow.scale = Vector2(1,1) * square_side_length
			is_right_click_pressed = true
		elif Input.is_action_pressed("right click"):
			var mouse_slide : Vector2 = scene.get_local_mouse_position() - start_mouse_position
			if mouse_slide.angle() >= 0:
				if mouse_slide.angle() > PI/4:
					if mouse_slide.angle() > PI/2:
						if mouse_slide.angle() > PI*3/4:
							#left down
							actual_arrow.rotation = PI*3/2
							actual_arrow.get_node("arrow").scale.x = 1
						else :
							#down left
							actual_arrow.rotation = PI
							actual_arrow.get_node("arrow").scale.x = -1
					else :
						#down right
						actual_arrow.rotation = PI
						actual_arrow.get_node("arrow").scale.x = 1
				else :
					#right down
					actual_arrow.rotation = PI/2
					actual_arrow.get_node("arrow").scale.x = -1
			
			else :
				if mouse_slide.angle() < -PI/4:
					if mouse_slide.angle() < -PI/2:
						if mouse_slide.angle() < -PI*3/4:
							#left up
							actual_arrow.rotation = PI*3/2
							actual_arrow.get_node("arrow").scale.x = -1
						else :
							#up left
							actual_arrow.rotation = 0
							actual_arrow.get_node("arrow").scale.x = 1
					else :
						#up right
						actual_arrow.rotation = 0
						actual_arrow.get_node("arrow").scale.x = -1
				else :
					#right up
					actual_arrow.rotation = PI/2
					actual_arrow.get_node("arrow").scale.x = 1
		elif is_right_click_pressed:
			is_right_click_pressed = false
			var is_arrow_already_created : bool = false
			for arrow in arrows.get_children():
				if not is_arrow_already_created:
					if arrow != actual_arrow:
						if arrow.global_transform == actual_arrow.global_transform:
							if arrow.get_node("arrow").global_transform == actual_arrow.get_node("arrow").global_transform:
								actual_arrow.queue_free()
								arrow.queue_free()
								is_arrow_already_created = true
		
		
		if Input.is_action_just_pressed("ui_cancel"):
			for arrow in arrows.get_children():
				arrow.queue_free()
		
		

func change_color_of_square(position : Vector2, color : Color):
	for square in squares_parent.get_children():
		if square.position == position:
			square.modulate = color

func reset():
	knight_placed = false
	for square in squares_parent.get_children():
		square.queue_free()

func init():
	make_grid()

func make_grid():
	grid = []
	square_side_length = window.size.y/grid_side
	if window.size.y > window.size.x:
		square_side_length = window.size.x/grid_side
	for x in grid_side:
		for y in grid_side:
			var color : Color = Color.WHITE
			if ckeck_skin:
				color = Color.BLACK
			if (y+x) % 2 == 0:
				color = Color.WHITE
			create_square(Vector2(x,y)*square_side_length, color)
			grid.append(true)

func create_square(position : Vector2, color : Color):
	var square : Node2D = square_scene.instantiate()
	square.position = position + Vector2(1,1)*square_side_length/2
	square.scale = Vector2(1,1) * square_side_length
	square.modulate = color
	if ckeck_skin:
		square.get_node("form/square").scale = Vector2(1,1)
	else :
		square.get_node("form/square").scale = Vector2(1,1)*0.9
	squares_parent.add_child(square)


func return_action() -> void:
	if actions.size() != 0:
		var color : Color = Color.WHITE
		if ckeck_skin:
			color = Color.BLACK
		grid[knight_position.x + knight_position.y*grid_side] = true
		if (knight_position.x+knight_position.y) % 2 == 0:
			color = Color.WHITE
		change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, color)
		knight_position -= knight_mouves[actions[-1]]
		knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
		canceled_actions.append(actions[-1])
		actions.remove_at(actions.size()-1)
	else:
		canceled_actions.append(start_knight_position)
		var color : Color = Color.WHITE
		if ckeck_skin:
			color = Color.BLACK
		grid[knight_position.x + knight_position.y*grid_side] = true
		if (knight_position.x+knight_position.y) % 2 == 0:
			color = Color.WHITE
		change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, color)
		knight_placed = false

func return_return_action() -> void:
	if canceled_actions.size() != 0:
		if canceled_actions[-1] is Vector2i:
			knight_position = canceled_actions[-1]
			knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
			grid[knight_position.x + knight_position.y*grid_side] = false
			change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, Color.RED)
			canceled_actions.remove_at(canceled_actions.size()-1)
			knight_placed = true
		else :
			var mouve = canceled_actions[-1]
			knight_position += knight_mouves[mouve]
			knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
			grid[knight_position.x + knight_position.y*grid_side] = false
			change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, Color.RED)
			actions.append(mouve)
			canceled_actions.remove_at(canceled_actions.size()-1)
			if grid.find(true) == -1:
				print([start_knight_position, actions])
