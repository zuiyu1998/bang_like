# 描述如何对属性进行更改
class_name SkillAttributeModifier
extends Resource

enum MoiferOperation {
	# 对属性进行数值更改
	ADD_ABSOLUTE,
	# 基于属性的基础值进行百分比操作
	MULTIPLY_BASE,
	# 基于属性的当前值进行百分比操作
	MULTIPLY_CURRENT,
	# 覆写属性的最终值
	OVERRIDE
}

# 用于更改的值
@export var value: float = 0.0
# 属性操作
@export var operation: MoiferOperation = MoiferOperation.ADD_ABSOLUTE
# 更改器来源的唯一标识
@export var source_uid: String = ""


func _init(p_value: float, p_operation: MoiferOperation, p_source_uid: String) -> void:
	value = p_value
	operation = p_operation
	source_uid = p_source_uid


func apply(attribute: SkillAttribute):
	match operation:
		MoiferOperation.ADD_ABSOLUTE:
			attribute.current_value += value
		MoiferOperation.MULTIPLY_BASE:
			attribute.current_value += attribute.base_value * value
		MoiferOperation.MULTIPLY_CURRENT:
			attribute.current_value = attribute.current_value * value
		MoiferOperation.OVERRIDE:
			attribute.current_value = value
