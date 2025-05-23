# 描述一个单位的所有属性
class_name SkillAttributeSet
extends Resource

## 默认的属性
@export var initialize_attributes: Array[SkillAttribute] = []

var initialized: bool = false
var _attributes: Dictionary = {}


func _get_attribute(attribute_name: StringName) -> SkillAttribute:
	if not initialized:
		printerr("[SkillAttributeSet] SkillAttributeSet not initialized")
		return null
	if not _attributes.has(attribute_name):
		printerr("[SkillAttributeSet] %s not initialized" % attribute_name)
		return null
	return _attributes[attribute_name]


# 初始化
func initialize():
	if initialized:
		return

	_attributes.clear()

	for initialize_attribute in initialize_attributes:
		var attribute = initialize_attribute.duplicate(true) as SkillAttribute
		attribute.current_value = attribute.base_value

	initialized = true
