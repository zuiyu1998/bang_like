# 这是描述属性的对象
class_name SkillAttribute
extends Resource

# 唯一标识符
@export var attribute_name: StringName = &""
# 属性名称
@export var display_name: String = ""
# 属性描述
@export_multiline var description: String = ""
# 属性的基础值
@export var base_value: float = 0.0
# 属性的最小值
@export var min_value: float = -INF
# 属性的最大值
@export var max_value: float = INF
# 可以为负
@export var can_be_negative: bool = false

# 当前值
var current_value: float = 0.0

# 属性更改器
var _active_modifiers: Array[SkillAttributeModifier] = []

# 设置基础值同时会触发当前值计算
func set_base_value(value: float):
	base_value = value
	_recalculate()


func get_active_modifiers() -> Array[SkillAttributeModifier]:
	return _active_modifiers.duplicate()


func _recalculate():
	var last_value = current_value

	var base_modifiers: Array[SkillAttributeModifier] = []
	var absolute_modifiers: Array[SkillAttributeModifier] = []
	var current_modifiers: Array[SkillAttributeModifier] = []
	var override_modifiers: Array[SkillAttributeModifier] = []

	for modifier: SkillAttributeModifier in _active_modifiers:
		match modifier.operation:
			SkillAttributeModifier.MoiferOperation.MULTIPLY_BASE:
				base_modifiers.append(modifier.duplicate())
			SkillAttributeModifier.MoiferOperation.ADD_ABSOLUTE:
				absolute_modifiers.append(modifier.duplicate())
			SkillAttributeModifier.MoiferOperation.MULTIPLY_CURRENT:
				current_modifiers.append(modifier.duplicate())
			SkillAttributeModifier.MoiferOperation.OVERRIDE:
				override_modifiers.append(modifier.duplicate())
	# 根据基础值百分比更改
	for modifier: SkillAttributeModifier in base_modifiers:
		modifier.apply(self)

	# 根据数值直接更改
	for modifier: SkillAttributeModifier in absolute_modifiers:
		modifier.apply(self)

	# 根据当前值直接更改
	for modifier: SkillAttributeModifier in current_modifiers:
		modifier.apply(self)

	# 直接覆盖
	for modifier: SkillAttributeModifier in override_modifiers:
		modifier.apply(self)

	var final_value = current_value
	if not can_be_negative and final_value < 0.0:
		final_value = 0.0

	current_value = clampf(final_value, min_value, max_value)

	return current_value != last_value


func remove_modifier(modifier: SkillAttributeModifier):
	if modifier in _active_modifiers:
		_active_modifiers.erase(modifier)
		_recalculate()


# 添加更改器
func add_modifier(modifier: SkillAttributeModifier):
	if not modifier in _active_modifiers:
		_active_modifiers.append(modifier)
		_recalculate()
		print_debug("[SkillAttribute] %s add_modifier %s" % [attribute_name, modifier.source_uid])
