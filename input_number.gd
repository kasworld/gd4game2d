class_name InputNumber extends HBoxContainer

signal value_changed(v :int)

func init(s :String,fontsize :float, v :int, minv :int, maxv :int)->void:
	$Label.text = s
	$Number.value = v
	$Number.min_value = minv
	$Number.max_value = maxv
	$Dec.text = "%s<=" % minv
	$Inc.text = "=>%s" % maxv
	theme.set_default_font_size(fontsize)

func get_value()->int:
	return $Number.value

var val_diff :float
var delay_sec :float = 0.3
var click_start :float

func enable(b :bool):
	$Dec.disabled = not b
	$Inc.disabled = not b
	$Number.editable = b
	val_diff = 0

func _process(_delta: float) -> void:
	if val_diff != 0:
		if Time.get_unix_time_from_system() - click_start > delay_sec:
			$Number.value += val_diff
			click_start = Time.get_unix_time_from_system()

func _on_dec_button_down() -> void:
	val_diff = -1
	click_start = Time.get_unix_time_from_system()
	$Number.value += val_diff

func _on_inc_button_down() -> void:
	val_diff = 1
	click_start = Time.get_unix_time_from_system()
	$Number.value += val_diff

func _on_dec_button_up() -> void:
	val_diff = 0
	emit_signal("value_changed",$Number.value)

func _on_inc_button_up() -> void:
	val_diff = 0
	emit_signal("value_changed",$Number.value)

func _on_number_value_changed(value: float) -> void:
	emit_signal("value_changed",value)
