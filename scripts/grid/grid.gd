# Grid - 5行×9列 网格战场管理系统
extends Node2D

const ROWS: int = 5
const COLS: int = 9
const CELL_WIDTH: int = 100
const CELL_HEIGHT: int = 100
const GRID_OFFSET_X: int = 40
const GRID_OFFSET_Y: int = 80

# 网格占用状态
var grid: Array = []

# 悬停高亮
var hovered_cell: Dictionary = { "row": -1, "col": -1 }

# 塔场景路径映射
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

func _initialize_grid() -> void:
	grid.clear()
	for r in range(ROWS):
		var row_data = []
		for c in range(COLS):
			row_data.append(null)
		grid.append(row_data)

func world_to_grid(world_pos: Vector2) -> Dictionary:
	var col = int((world_pos.x - GRID_OFFSET_X) / CELL_WIDTH)
	var row = int((world_pos.y - GRID_OFFSET_Y) / CELL_HEIGHT)
	return { "row": row, "col": col }

func grid_to_world(row: int, col: int) -> Vector2:
	return Vector2(
		GRID_OFFSET_X + col * CELL_WIDTH + CELL_WIDTH / 2.0,
		GRID_OFFSET_Y + row * CELL_HEIGHT + CELL_HEIGHT / 2.0
	)

func is_valid_cell(row: int, col: int) -> bool:
	return row >= 0 and row < ROWS and col >= 0 and col < COLS

func is_cell_empty(row: int, col: int) -> bool:
	if not is_valid_cell(row, col):
		return false
	return grid[row][col] == null

func place_plant(row: int, col: int, plant_type: int) -> bool:
	if not is_cell_empty(row, col):
		return false
	grid[row][col] = plant_type

	# 实例化塔场景
	var scene_path = tower_scenes.get(plant_type, "")
	if not scene_path.is_empty():
		var tower_scene = load(scene_path)
		if tower_scene:
			var tower = tower_scene.instantiate()
			tower.position = grid_to_world(row, col)
			tower.setup(plant_type, self)
			tower.row = row
			tower.col = col
			var towers_container = get_node_or_null("../Towers")
			if towers_container:
				towers_container.add_child(tower)

	plant_placed.emit(row, col, plant_type)
	return true

func remove_plant(row: int, col: int) -> void:
	if is_valid_cell(row, col):
		grid[row][col] = null
		plant_removed.emit(row, col)

func get_plant_at(row: int, col: int):
	if not is_valid_cell(row, col):
		return null
	return grid[row][col]

func get_enemies_in_row(row: int) -> Array:
	var enemies_in_row = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.row == row and enemy.is_alive:
			enemies_in_row.append(enemy)
	enemies_in_row.sort_custom(func(a, b): return a.position.x > b.position.x)
	return enemies_in_row

func get_cells_in_range(row: int, col: int, radius: int = 1) -> Array:
	var cells = []
	for r in range(max(0, row - radius), min(ROWS, row + radius + 1)):
		for c in range(max(0, col - radius), min(COLS, col + radius + 1)):
			cells.append({ "row": r, "col": c })
	return cells

func get_enemies_in_range(row: int, col: int, radius: int = 1) -> Array:
	var enemies = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_alive:
			continue
		if abs(enemy.row - row) <= radius and abs(enemy.col - col) <= radius:
			enemies.append(enemy)
	return enemies

# 获取阳光管理器
func get_sun_manager() -> Node:
	return get_node_or_null("/root/Main/GameManager/SunManager")

# 鼠标输入处理
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()

	# 悬停追踪
	if event is InputEventMouseMotion:
		_update_hover(event.position)

# 处理点击
func _handle_click(click_pos: Vector2) -> void:
	var cell = world_to_grid(click_pos)
	if not is_valid_cell(cell.row, cell.col):
		return

	var card_bar = get_node_or_null("/root/Main/CardBar")
	if not card_bar or card_bar.selected_plant < 0:
		return

	# 尝试放置
	var gm = get_node_or_null("/root/Main/GameManager")
	if not gm:
		return

	var plant_type = card_bar.selected_plant
	if not is_cell_empty(cell.row, cell.col):
		return

	var cost = GameData.get_cost(plant_type)
	if not gm.spend_sun(cost):
		return  # 阳光不够

	place_plant(cell.row, cell.col, plant_type)
	card_bar.deselect_all()

# 取消选择
func _cancel_placement() -> void:
	var card_bar = get_node_or_null("/root/Main/CardBar")
	if card_bar:
		card_bar.deselect_all()

# 更新悬停高亮
func _update_hover(mouse_pos: Vector2) -> void:
	var cell = world_to_grid(mouse_pos)
	if cell.row == hovered_cell.row and cell.col == hovered_cell.col:
		return  # 未变化

	hovered_cell = cell
	queue_redraw()

# 渲染网格
func _draw() -> void:
	for r in range(ROWS):
		for c in range(COLS):
			var pos = Vector2(
				GRID_OFFSET_X + c * CELL_WIDTH,
				GRID_OFFSET_Y + r * CELL_HEIGHT
			)
			var color = Color(0.3, 0.6, 0.2)
			if (r + c) % 2 == 0:
				color = Color(0.35, 0.65, 0.25)
			draw_rect(Rect2(pos, Vector2(CELL_WIDTH, CELL_HEIGHT)), color)
			draw_rect(Rect2(pos, Vector2(CELL_WIDTH, CELL_HEIGHT)), Color(0.2, 0.4, 0.15), false, 1.0)

	# 悬停高亮
	if is_valid_cell(hovered_cell.row, hovered_cell.col):
		var hl_pos = Vector2(
			GRID_OFFSET_X + hovered_cell.col * CELL_WIDTH,
			GRID_OFFSET_Y + hovered_cell.row * CELL_HEIGHT
		)
		var card_bar = get_node_or_null("/root/Main/CardBar")
		if card_bar and card_bar.selected_plant >= 0:
			var is_empty = is_cell_empty(hovered_cell.row, hovered_cell.col)
			var hl_color = Color(1.0, 1.0, 1.0, 0.4) if is_empty else Color(1.0, 0.2, 0.2, 0.4)
			draw_rect(Rect2(hl_pos, Vector2(CELL_WIDTH, CELL_HEIGHT)), hl_color)
