# 描述一个单位的所有属性
class_name SkillAttributeSet
extends Resource

## 默认的属性
@export var initialize_attributes: Array[SkillAttribute] = []

var initialized: bool = false
var _attributes: Dictionary = {}


# 初始化属性的当前值
func initialize_attribute_current_value(_attribute: SkillAttribute, old_current_value: float) -> float:
	return old_current_value


# 在设置基础值前更新
func after_current_value_change(attribute: SkillAttribute, _old_value: float, new_value: float, _source_uid: Variant = null):
	attribute.current_value = new_value


# 在设置基础值前更新
func after_base_value_change(attribute: SkillAttribute, _old_value: float, new_value: float, _source_uid: Variant = null):
	attribute.base_value = new_value


# 在设置基础值前更新
func before_base_value_change(_attribute: SkillAttribute, _old_value: float, new_value: float, _source_uid: Variant = null) -> float:
	return new_value


# 在设置当前值前更新
func before_current_value_change(_attribute: SkillAttribute, _old_value: float, new_value: float, _source_uid: Variant = null) -> float:
	return new_value


func remove_modifer(attribute_name: StringName, source_uid: String):
	var attr: SkillAttribute = _get_attribute(attribute_name)
	if not attr:
		return false

	var temp = attr.get_active_modifiers()

	for m in temp:
		if m.source_uid == source_uid:
			attr.remove_modifier(m)

	var new_current = attr.current_value
	set_current_value(attribute_name, new_current, source_uid)


func apply_modifer(attribute_name: StringName, modifier: SkillAttributeModifier):
	var attr: SkillAttribute = _get_attribute(attribute_name)
	if not attr:
		return false

	attr.add_modifier(modifier)

	var new_current = attr.current_value
	set_current_value(attribute_name, new_current, modifier.source_uid)


# 设置当前值
func set_current_value(attribute_name: StringName, current_value: float, source_uid: Variant = null):
	var attr: SkillAttribute = _get_attribute(attribute_name)
	if not attr:
		return false
	
	var old_current = attr.current_value
	var final_value = before_current_value_change(attr, old_current, current_value, source_uid)
	attr.current_value = final_value

	var new_current = attr.current_value
	after_current_value_change(attr, old_current, new_current, source_uid)


# 设置当前值
func set_base_value(attribute_name: StringName, base_value: float, source_uid: Variant = null) -> bool:
	var attr: SkillAttribute = _get_attribute(attribute_name)
	if not attr:
		return false
	
	var old_base = attr.base_value
	if old_base == base_value:
		return false

	var final_value = before_base_value_change(attr, old_base, base_value, source_uid)

	if old_base == final_value:
		return false

	var old_current = attr.current_value
	
	attr.set_base_value(final_value)
	
	var new_current = attr.current_value

	after_base_value_change(attr, old_base, attr.base_value, source_uid)

	if old_current != new_current:
		set_current_value(attribute_name, new_current, source_uid)
	
	return true


func get_base_value(attribute_name: StringName) -> float:
	var attr := _get_attribute(attribute_name)
	if not attr:
		return 0.0
	else:
		return attr.base_value


func get_current_value(attribute_name: StringName) -> float:
	var attr := _get_attribute(attribute_name)
	if not attr:
		return 0.0
	else:
		return attr.current_value


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
		_attributes[initialize_attribute.attribute_name] = initialize_attribute

	for attribute: SkillAttribute in _attributes.values():
		var old_value = attribute.current_value
		var final_value = initialize_attribute_current_value(attribute, old_value)
		attribute.current_value = final_value

	initialized = true
