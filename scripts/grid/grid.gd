# Grid - 5行×9列 网格战场管理系统（美化版）
extends Node2D

const ROWS: int = 5
const COLS: int = 9
const CELL_W: int = 100
const CELL_H: int = 100
const OFFSET_X: int = 40
const OFFSET_Y: int = 80

var grid: Array = []
var hovered_cell: Dictionary = { "row": -1, "col": -1 }
var anim_time: float = 0.0

var tower_scenes = {
	GameData.PlantType.PEASHOOTER: "res://scenes/peashooter.tscn",
	GameData.PlantType.SNOW_PEA: "res://scenes/snow_pea.tscn",
	GameData.PlantType.SUNFLOWER: "res://scenes/sunflower.tscn",
	GameData.PlantType.WALL_NUT: "res://scenes/wall_nut.tscn",
	GameData.PlantType.CHERRY_BOMB: "res://scenes/cherry_bomb.tscn",
}

signal cell_clicked(row: int, col: int)
signal plant_placed(row: int, col: int, plant_type: int)
signal plant_removed(row: int, col: int)

func _ready() -> void:
	_initialize_grid()
	set_process_input(true)
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _initialize_grid() -> void:
	grid.clear()
	for r in range(ROWS):
		var row_data = []
		for c in range(COLS):
			row_data.append(null)
		grid.append(row_data)

func world_to_grid(world_pos: Vector2) -> Dictionary:
	var col = int((world_pos.x - OFFSET_X) / CELL_W)
	var row = int((world_pos.y - OFFSET_Y) / CELL_H)
	return { "row": row, "col": col }

func grid_to_world(row: int, col: int) -> Vector2:
	return Vector2(OFFSET_X + col * CELL_W + CELL_W / 2.0, OFFSET_Y + row * CELL_H + CELL_H / 2.0)

func is_valid_cell(row: int, col: int) -> bool:
	return row >= 0 and row < ROWS and col >= 0 and col < COLS

func is_cell_empty(row: int, col: int) -> bool:
	if not is_valid_cell(row, col): return false
	return grid[row][col] == null

func place_plant(row: int, col: int, plant_type: int) -> bool:
	if not is_cell_empty(row, col): return false
	grid[row][col] = plant_type
	var scene_path = tower_scenes.get(plant_type, "")
	if not scene_path.is_empty():
		var scene = load(scene_path)
		if scene:
			var tower = scene.instantiate()
			tower.position = grid_to_world(row, col)
			tower.setup(plant_type, self)
			tower.row = row
			tower.col = col
			var tc = get_node_or_null("../Towers")
			if tc: tc.add_child(tower)
	plant_placed.emit(row, col, plant_type)
	return true

func remove_plant(row: int, col: int) -> void:
	if is_valid_cell(row, col):
		grid[row][col] = null
		plant_removed.emit(row, col)

func get_plant_at(row: int, col: int):
	return grid[row][col] if is_valid_cell(row, col) else null

func get_enemies_in_row(row: int) -> Array:
	var arr = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.row == row and e.is_alive: arr.append(e)
	arr.sort_custom(func(a, b): return a.position.x > b.position.x)
	return arr

func get_cells_in_range(row: int, col: int, radius: int = 1) -> Array:
	var cells = []
	for r in range(max(0, row - radius), min(ROWS, row + radius + 1)):
		for c in range(max(0, col - radius), min(COLS, col + radius + 1)):
			cells.append({"row": r, "col": c})
	return cells

func get_enemies_in_range(row: int, col: int, radius: int = 1) -> Array:
	var enemies = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.is_alive: continue
		if abs(e.row - row) <= radius and abs(e.col - col) <= radius:
			enemies.append(e)
	return enemies

func get_sun_manager() -> Node:
	return get_node_or_null("/root/Main/GameManager/SunManager")

# ==================== 输入处理 ====================

func _input(event: InputEvent) -> void:
	# 鼠标移动悬停（始终追踪）
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	# 点击放在这里确保收到（不受 Control 节点拦截）
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()

func _handle_click(click_pos: Vector2) -> void:
	var cell = world_to_grid(click_pos)
	if not is_valid_cell(cell.row, cell.col): return
	var cb = get_node_or_null("/root/Main/CardBar")
	if not cb or cb.selected_plant < 0: return
	var gm = get_node_or_null("/root/Main/GameManager")
	if not gm: return
	if gm.current_state != 1: return  # not PLAYING
	var pt = cb.selected_plant
	if not is_cell_empty(cell.row, cell.col): return
	if not gm.spend_sun(GameData.get_cost(pt)): return
	place_plant(cell.row, cell.col, pt)
	cb.deselect_all()

func _cancel_placement() -> void:
	var cb = get_node_or_null("/root/Main/CardBar")
	if cb: cb.deselect_all()

func _update_hover(mouse_pos: Vector2) -> void:
	var cell = world_to_grid(mouse_pos)
	if cell.row == hovered_cell.row and cell.col == hovered_cell.col: return
	hovered_cell = cell

# ==================== 渲染 ====================

func _draw() -> void:
	_draw_lawn()
	_draw_grid_lines()
	_draw_path_markers()
	_draw_hover()

func _draw_lawn() -> void:
	var total_w = COLS * CELL_W
	var total_h = ROWS * CELL_H
	draw_rect(Rect2(OFFSET_X - 8, OFFSET_Y - 8, total_w + 16, total_h + 16), Color(0.25, 0.18, 0.1), true)
	draw_rect(Rect2(OFFSET_X, OFFSET_Y, total_w, total_h), Color(0.25, 0.45, 0.15))
	for r in range(ROWS):
		for c in range(COLS):
			var x = OFFSET_X + c * CELL_W
			var y = OFFSET_Y + r * CELL_H
			var shade = 1.0 + sin((r + c) * 1.2 + anim_time * 0.3) * 0.05
			var c1 = Color(0.22, 0.50, 0.14) * shade
			var c2 = Color(0.28, 0.55, 0.18) * shade
			draw_rect(Rect2(x, y, CELL_W, CELL_H), c1 if (r + c) % 2 == 0 else c2)
			_draw_grass_detail(x, y, r, c)

func _draw_grass_detail(x: float, y: float, r: int, c: int) -> void:
	var seed = (r * 31 + c * 17) % 100
	for i in range(3):
		var gx = x + 12 + (seed + i * 23) % 76
		var gy = y + 12 + (seed + i * 37) % 76
		draw_circle(Vector2(gx, gy), 2.0, Color(0.15, 0.40, 0.10, 0.3))

func _draw_grid_lines() -> void:
	var lc = Color(0.15, 0.35, 0.10, 0.4)
	for r in range(ROWS + 1):
		var y = OFFSET_Y + r * CELL_H
		draw_line(Vector2(OFFSET_X, y), Vector2(OFFSET_X + COLS * CELL_W, y), lc, 1.0)
	for c in range(COLS + 1):
		var x = OFFSET_X + c * CELL_W
		draw_line(Vector2(x, OFFSET_Y), Vector2(x, OFFSET_Y + ROWS * CELL_H), lc, 1.0)

func _draw_path_markers() -> void:
	var pc = Color(0.6, 0.55, 0.4, 0.6)
	draw_rect(Rect2(OFFSET_X - 4, OFFSET_Y, 4, ROWS * CELL_H), pc)
	for r in range(ROWS):
		var y = OFFSET_Y + r * CELL_H + CELL_H / 2.0
		draw_circle(Vector2(OFFSET_X - 6, y), 5, Color(0.8, 0.2, 0.2, 0.7))
	var ec = Color(0.5, 0.2, 0.2, 0.4)
	draw_rect(Rect2(OFFSET_X + COLS * CELL_W, OFFSET_Y, 6, ROWS * CELL_H), ec)

func _draw_hover() -> void:
	if not is_valid_cell(hovered_cell.row, hovered_cell.col): return
	var x = OFFSET_X + hovered_cell.col * CELL_W
	var y = OFFSET_Y + hovered_cell.row * CELL_H
	var cb = get_node_or_null("/root/Main/CardBar")
	if cb and cb.selected_plant >= 0:
		var can = is_cell_empty(hovered_cell.row, hovered_cell.col)
		var hl = Color(1.0, 1.0, 0.3, 0.45) if can else Color(1.0, 0.15, 0.15, 0.45)
		draw_rect(Rect2(x + 2, y + 2, CELL_W - 4, CELL_H - 4), hl)
		draw_rect(Rect2(x, y, CELL_W, CELL_H), hl.lightened(0.2), false, 2.0)
