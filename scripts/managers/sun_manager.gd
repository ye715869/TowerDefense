# SunManager - 阳光掉落/收集管理
extends Node

var sky_fall_timer: float = 0.0
var sky_fall_interval: float = 10.0  # 每10秒掉一个

@onready var game_manager: Node = null

func _ready() -> void:
	game_manager = get_parent()
	sky_fall_timer = sky_fall_interval

func _process(delta: float) -> void:
	if not game_manager or game_manager.current_state != 1:
		return

	sky_fall_timer -= delta
	if sky_fall_timer <= 0:
		_spawn_sky_sun()
		sky_fall_timer = sky_fall_interval

# 获取战场节点（添加到 Battlefield 确保阳光渲染在战场之上，而非被遮挡）
func _get_battlefield() -> Node2D:
	return get_node_or_null("/root/Main/Battlefield")

# 天降阳光
func _spawn_sky_sun() -> void:
	var sun_scene = load("res://scenes/sun.tscn")
	if not sun_scene:
		return

	var battlefield = _get_battlefield()
	if not battlefield:
		return

	var sun_instance = sun_scene.instantiate()
	# 随机 x 位置（战场范围内）
	var x_min = 40.0
	var x_max = 40.0 + 9 * 100  # 9列 × 100px
	var x = randf_range(x_min + 50, x_max - 50)
	var y = randf_range(30, 200)  # 天上掉落
	sun_instance.position = Vector2(x, y)
	sun_instance.amount = 25
	battlefield.add_child(sun_instance)

# 植物生产阳光（由 Tower 调用）
func add_sun(amount: int, source_position: Vector2) -> void:
	var sun_scene = load("res://scenes/sun.tscn")
	if not sun_scene:
		return

	var battlefield = _get_battlefield()
	if not battlefield:
		return

	var sun_instance = sun_scene.instantiate()
	sun_instance.position = source_position + Vector2(randf_range(-20, 20), -30)
	sun_instance.amount = amount
	battlefield.add_child(sun_instance)
