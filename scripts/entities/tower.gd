# Tower - 防御塔基类
class_name Tower
extends Node2D

# 基本属性（由子类或数据表设置）
var plant_type: int = -1
var tower_name: String = ""
var health: float = 100.0
var max_health: float = 100.0
var damage: float = 0.0
var attack_speed: float = 0.0
var attack_range: float = 0.0
var cost: int = 0
var sun_production: int = 0
var sun_interval: float = 0.0

# 运行时状态
var row: int = -1
var col: int = -1
var attack_timer: float = 0.0
var sun_timer: float = 0.0
var is_alive: bool = true
var is_one_shot: bool = false  # 一次性植物（如樱桃炸弹）
var slow_amount: float = 0.0
var slow_duration: float = 0.0

@onready var body: ColorRect = null
@onready var grid_ref: Node2D = null

func _ready() -> void:
	add_to_group("towers")

func setup(type: int, grid_node: Node2D) -> void:
	plant_type = type
	grid_ref = grid_node
	var data = GameData.get_plant(type)
	if data.is_empty():
		return

	tower_name = data.get("name", "???")
	health = data.get("health", 100.0)
	max_health = health
	damage = data.get("damage", 0.0)
	attack_speed = data.get("attack_speed", 0.0)
	attack_range = data.get("range", 0)
	cost = data.get("cost", 0)
	sun_production = data.get("sun_production", 0)
	sun_interval = data.get("sun_interval", 0.0)
	slow_amount = data.get("slow_amount", 0.0)
	slow_duration = data.get("slow_duration", 0.0)
	is_one_shot = data.get("one_shot", false)

	attack_timer = attack_speed  # 首次攻击等待一个周期
	sun_timer = sun_interval

	_draw_placeholder()

func _process(delta: float) -> void:
	if not is_alive:
		return

	# 阳光生产
	if sun_production > 0 and sun_interval > 0:
		sun_timer -= delta
		if sun_timer <= 0:
			_produce_sun()
			sun_timer = sun_interval

	# 攻击逻辑
	if damage > 0 and attack_speed > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			_attack()
			attack_timer = attack_speed

# 绘制占位几何图形（开发阶段）
func _draw_placeholder() -> void:
	# 移除旧图形
	for child in get_children():
		if child is ColorRect and child != body:
			child.queue_free()

	var data = GameData.get_plant(plant_type)
	var color = data.get("color", Color.WHITE)

	# 主体
	body = ColorRect.new()
	body.color = color
	body.size = Vector2(60, 60)
	body.position = Vector2(-30, -30)
	add_child(body)

	# 血量条
	if max_health > 0:
		var hp_bg = ColorRect.new()
		hp_bg.color = Color(0.3, 0.3, 0.3)
		hp_bg.size = Vector2(60, 6)
		hp_bg.position = Vector2(-30, -40)
		add_child(hp_bg)

		var hp_fill = ColorRect.new()
		hp_fill.name = "HPFill"
		hp_fill.color = Color(0, 1, 0)
		hp_fill.size = Vector2(60, 6)
		hp_fill.position = Vector2(-30, -40)
		add_child(hp_fill)

	# 标签
	var label = Label.new()
	label.text = tower_name
	label.add_theme_font_size_override("font_size", 10)
	label.position = Vector2(-30, 35)
	label.size = Vector2(60, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

# 攻击方法（子类重写）
func _attack() -> void:
	pass

# 生产阳光
func _produce_sun() -> void:
	if sun_production <= 0:
		return
	if grid_ref and grid_ref.has_method("get_sun_manager"):
		var sun_mgr = grid_ref.get_sun_manager()
		if sun_mgr:
			sun_mgr.add_sun(sun_production, global_position)

# 受到伤害
func take_damage(amount: float) -> void:
	if not is_alive:
		return
	health -= amount
	_update_hp_bar()
	if health <= 0:
		_die()

# 更新血量条
func _update_hp_bar() -> void:
	var hp_fill = get_node_or_null("HPFill")
	if hp_fill:
		var ratio = clamp(health / max_health, 0.0, 1.0)
		hp_fill.size.x = 60.0 * ratio
		if ratio < 0.3:
			hp_fill.color = Color.RED
		elif ratio < 0.6:
			hp_fill.color = Color.YELLOW

# 死亡
func _die() -> void:
	is_alive = false
	if grid_ref and row >= 0 and col >= 0:
		grid_ref.remove_plant(row, col)
	queue_free()
