# CardBar - 底部植物选择卡片栏
extends Control

# 当前选中的植物类型
var selected_plant: int = -1
var selected_card: Node = null

# 游戏管理器引用
@onready var game_manager: Node = null

# 卡片节点列表
var cards: Array = []

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	_create_cards()

func _create_cards() -> void:
	# 底部背景
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.15, 0.9)
	bg.size = Vector2(1000, 110)
	bg.position = Vector2(0, 550)
	add_child(bg)

	# 植物类型和顺序
	var plant_types = [
		GameData.PlantType.SUNFLOWER,
		GameData.PlantType.PEASHOOTER,
		GameData.PlantType.SNOW_PEA,
		GameData.PlantType.WALL_NUT,
		GameData.PlantType.CHERRY_BOMB,
	]

	for i in range(plant_types.size()):
		var plant_type = plant_types[i]
		var card_scene = load("res://scenes/plant_card.tscn")
		if not card_scene:
			continue

		var card = card_scene.instantiate()
		card.position = Vector2(20 + i * 110, 558)
		card.setup(plant_type)
		card.card_clicked.connect(_on_card_clicked)
		add_child(card)
		cards.append(card)

	# 铲子按钮
	var shovel = Button.new()
	shovel.text = "🔧"
	shovel.position = Vector2(580, 570)
	shovel.size = Vector2(50, 50)
	shovel.pressed.connect(_on_shovel_pressed)
	add_child(shovel)

	# 取消选择提示
	var cancel_label = Label.new()
	cancel_label.text = "右键取消选择"
	cancel_label.add_theme_font_size_override("font_size", 12)
	cancel_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	cancel_label.position = Vector2(640, 585)
	cancel_label.size = Vector2(120, 20)
	add_child(cancel_label)

func _on_card_clicked(plant_type: int) -> void:
	# 检查阳光是否足够
	if game_manager and not game_manager.can_place_plant(plant_type):
		return

	# 如果已选中，取消选择
	if selected_plant == plant_type:
		deselect_all()
		return

	deselect_all()
	selected_plant = plant_type

func deselect_all() -> void:
	selected_plant = -1
	for card in cards:
		if card.has_method("set_selected"):
			card.set_selected(false)

func _on_shovel_pressed() -> void:
	# TODO: 铲除模式
	pass
