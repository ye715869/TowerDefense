# GameManager - 游戏主状态管理
extends Node

# 游戏状态
enum GameState {
	READY,       # 准备开始
	PLAYING,     # 游戏中
	PAUSED,      # 暂停
	VICTORY,     # 胜利
	DEFEAT,      # 失败
}

var current_state: int = GameState.READY
var current_level: int = 1
var current_wave: int = 0
var total_waves: int = 0

# 基地血量
var base_health: float = 100.0
var max_base_health: float = 100.0

# 阳光
var sun: int = 150

# 引用
@onready var hud = null
@onready var sun_manager = null
@onready var wave_manager = null
@onready var card_bar = null
@onready var grid = null

# 信号
signal sun_changed(new_amount: int)
signal base_health_changed(new_health: float)
signal state_changed(new_state: int)
signal wave_changed(current: int, total: int)

func _ready() -> void:
	# 获取子节点引用
	hud = get_node_or_null("HUD")
	sun_manager = get_node_or_null("SunManager")
	wave_manager = get_node_or_null("WaveManager")
	card_bar = get_node_or_null("CardBar")
	grid = get_node_or_null("Battlefield/Grid")

func start_level(level_num: int) -> void:
	current_level = level_num
	current_wave = 0
	var level_data = WaveConfig.get_level(level_num)
	if level_data.is_empty():
		return

	total_waves = WaveConfig.get_wave_count(level_num)
	sun = level_data.get("initial_sun", 150)
	sun_changed.emit(sun)

	current_state = GameState.PLAYING
	state_changed.emit(current_state)

	if wave_manager:
		wave_manager.start_level(level_num)

func next_wave() -> void:
	current_wave += 1
	if current_wave > total_waves:
		_victory()
		return

	wave_changed.emit(current_wave, total_waves)
	if wave_manager:
		wave_manager.spawn_wave(current_wave)

# 消耗阳光（放置植物时调用）
func spend_sun(amount: int) -> bool:
	if sun >= amount:
		sun -= amount
		sun_changed.emit(sun)
		return true
	return false

# 增加阳光
func add_sun(amount: int) -> void:
	sun += amount
	sun_changed.emit(sun)

# 击杀敌人奖励阳光
func add_sun_reward(amount: int) -> void:
	sun += amount
	sun_changed.emit(sun)

# 敌人到达底线，对基地造成伤害
func damage_base(amount: float) -> void:
	base_health -= amount
	base_health_changed.emit(base_health)
	if base_health <= 0:
		_defeat()

func _victory() -> void:
	current_state = GameState.VICTORY
	state_changed.emit(current_state)

func _defeat() -> void:
	current_state = GameState.DEFEAT
	state_changed.emit(current_state)

# 获取阳光管理器（供 Tower 调用）
func get_sun_manager() -> Node:
	return sun_manager

# 检查是否可以放置植物
func can_place_plant(plant_type: int) -> bool:
	if current_state != GameState.PLAYING:
		return false
	var cost = GameData.get_cost(plant_type)
	return sun >= cost
