extends HBoxContainer

func init(s :String, v :int, min :int, max :int)->void:
	$Label.text = s
	$Number.value = v
	$Number.min_value = min
	$Number.max_value = max

func get_value()->int:
	return $Number.value

func _on_dec_pressed() -> void:
	$Number.value -=1

func _on_inc_pressed() -> void:
	$Number.value +=1
