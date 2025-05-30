extends Node

@export var square_scene : PackedScene
@export var grid_side : int = 8
@onready var scene : Node2D = get_node("scene")
@onready var squares_parent : Node2D = scene.get_node("squares")
@onready var knight : Node2D = scene.get_node("knight")
@onready var window : Window = get_window()
var knight_position : Vector2i = Vector2i.ZERO
var square_side_length : int = 0
var knight_placed : bool = false
var grid : Array = []
var actions : Array = []


func _ready() -> void:
	init()

func _process(delta: float) -> void:
	knight.scale = Vector2(1,1) * square_side_length
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
				knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
				change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, Color.RED)
				grid[knight_position.x + knight_position.y*grid_side] = false
	else :
		knight.get_node("form/arrows").show()
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
	for x in grid_side:
		for y in grid_side:
			var color : Color = Color.WHITE#
			if (y+x) % 2 == 0:
				color = Color.WHITE
			create_square(Vector2(x,y)*square_side_length, color)
			grid.append(true)

func create_square(position : Vector2, color : Color):
	var square : Node2D = square_scene.instantiate()
	square.position = position + Vector2(1,1)*square_side_length/2
	square.scale = Vector2(1,1) * square_side_length
	square.modulate = color
	squares_parent.add_child(square)


func return_action() -> void:
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
		
	if actions.size() != 0:
		var color : Color = Color.WHITE#
		grid[knight_position.x + knight_position.y*grid_side] = true
		if (knight_position.x+knight_position.y) % 2 == 0:
			color = Color.WHITE
		change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, color)
		knight_position -= knight_mouves[actions[-1]]
		knight.position = squares_parent.position + Vector2(1,1)*square_side_length/2 + Vector2(knight_position) * square_side_length
		actions.remove_at(actions.size()-1)
	else:
		var color : Color = Color.WHITE#
		grid[knight_position.x + knight_position.y*grid_side] = true
		if (knight_position.x+knight_position.y) % 2 == 0:
			color = Color.WHITE
		change_color_of_square(Vector2(knight_position)*square_side_length + Vector2(1,1)*square_side_length/2, color)
		knight_placed = false
