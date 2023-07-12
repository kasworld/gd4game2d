extends HBoxContainer

func init(s :String, v :int, minv :int, maxv :int)->void:
	$Label.text = s
	$Number.value = v
	$Number.min_value = minv
	$Number.max_value = maxv

func get_value()->int:
	return $Number.value

func _on_dec_pressed() -> void:
	$Number.value -=1

func _on_inc_pressed() -> void:
	$Number.value +=1
