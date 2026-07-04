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

# 基地血量
var base_health: float = 100.0
var max_base_health: float = 100.0

# 阳光
var sun: int = 150

# 植物冷却追踪 {plant_type: remaining_cooldown}
var cooldowns: Dictionary = {}
var cheat_mode: bool = false

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
signal cooldown_updated(plant_type: int, remaining: float)

func _ready() -> void:
	hud = get_node_or_null("HUD")
	sun_manager = get_node_or_null("SunManager")
	wave_manager = get_node_or_null("WaveManager")
	card_bar = get_node_or_null("CardBar")
	grid = get_node_or_null("Battlefield/Grid")

	# 连接波次管理器的信号
	if wave_manager:
		wave_manager.wave_notification.connect(_on_wave_notification)
		wave_manager.wave_changed.connect(_on_wave_manager_wave_changed)
		wave_manager.all_enemies_cleared.connect(_on_all_enemies_cleared)

func _process(delta: float) -> void:
	# 更新冷却时间
	if current_state == GameState.PLAYING:
		var keys = cooldowns.keys()
		for pt in keys:
			cooldowns[pt] -= delta
			if cooldowns[pt] <= 0:
				cooldowns.erase(pt)
				cooldown_updated.emit(pt, 0.0)
			else:
				cooldown_updated.emit(pt, cooldowns[pt])

func start_level(level_num: int) -> void:
	current_level = level_num
	sun = 150
	cooldowns.clear()
	sun_changed.emit(sun)
	base_health = 100.0
	max_base_health = 100.0
	base_health_changed.emit(base_health)

	current_state = GameState.PLAYING
	state_changed.emit(current_state)

	if wave_manager:
		wave_manager.start_level(level_num)

	wave_changed.emit(0, 3)

func restart_game() -> void:
	cooldowns.clear()
	# 清除所有敌人
	for e in get_tree().get_nodes_in_group("enemies"):
		e.is_alive = false
		e.queue_free()
	# 清除所有植物
	for t in get_tree().get_nodes_in_group("towers"):
		t.is_alive = false
		t.queue_free()
	# 清除所有子弹
	for p in get_tree().get_nodes_in_group("projectiles"):
		p.queue_free()
	# 清除阳光实体
	for s in get_tree().get_nodes_in_group("suns"):
		s.queue_free()
	# 重置网格
	if grid and grid.has_method("_initialize_grid"):
		grid._initialize_grid()

	current_state = GameState.READY
	state_changed.emit(current_state)

func quit_game() -> void:
	get_tree().quit()

# 消耗阳光 + 启动冷却
func spend_sun(amount: int, plant_type: int = -1) -> bool:
	if cheat_mode:
		return true  # 作弊模式：不扣阳光，无冷却
	if sun >= amount:
		sun -= amount
		sun_changed.emit(sun)
		if plant_type >= 0:
			var cd = GameData.get_cooldown(plant_type)
			if cd > 0:
				cooldowns[plant_type] = cd
				cooldown_updated.emit(plant_type, cd)
		return true
	return false

# 强制跳波
func force_wave() -> void:
	if wave_manager and current_state == GameState.PLAYING:
		wave_manager.force_wave()

# 增加阳光
func add_sun(amount: int) -> void:
	sun += amount
	sun_changed.emit(sun)

# 敌人到达底线
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

func get_sun_manager() -> Node:
	return sun_manager

func can_place_plant(plant_type: int) -> bool:
	if current_state != GameState.PLAYING:
		return false
	if cheat_mode:
		return true
	var cost = GameData.get_cost(plant_type)
	if sun < cost:
		return false
	if plant_type in cooldowns and cooldowns[plant_type] > 0:
		return false
	return true

func toggle_cheat() -> bool:
	cheat_mode = not cheat_mode
	if cheat_mode:
		# 开启作弊时立刻清除所有植物冷却
		for pt in cooldowns.keys():
			cooldowns.erase(pt)
			cooldown_updated.emit(pt, 0.0)
	return cheat_mode

func get_plant_cooldown(plant_type: int) -> float:
	return cooldowns.get(plant_type, 0.0)

func is_wave_in_progress() -> bool:
	if not wave_manager:
		return false
	var info = wave_manager.get_wave_info()
	var s = info.get("state", 0)
	return s == 2 or s == 3  # WAVE or FINAL_WAVE

func can_skip_wave() -> bool:
	if not wave_manager:
		return false
	var info = wave_manager.get_wave_info()
	var s = info.get("state", 0)
	var wn = info.get("wave_num", 0)
	# 只在常态化刷新时可用，且波数未满
	return (s == 1) and (wn < 3)  # NORMAL state and not finished

# 回调
func _on_wave_notification(text: String) -> void:
	if hud and hud.has_method("show_notification"):
		hud.show_notification(text)

func _on_wave_manager_wave_changed(current: int, total: int) -> void:
	wave_changed.emit(current, total)

func _on_all_enemies_cleared() -> void:
	_victory()
