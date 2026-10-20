extends VNEngineAnimation


func play(target: CanvasItem, params: Dictionary) -> void:
	var control: Control = target as Control
	if control == null:
		return
	var angle: float = float(params.get("angle", 0.08))
	var times: int = int(params.get("times", 2))
	var old_pivot: Vector2 = control.pivot_offset
	var old_rotation: float = control.rotation
	control.pivot_offset = Vector2(control.size.x / 2.0, control.size.y)
	var tween: Tween = control.create_tween()
	for i in times:
		tween.tween_property(control, "rotation", old_rotation + angle, 0.12)
		tween.tween_property(control, "rotation", old_rotation - angle, 0.12)
	tween.tween_property(control, "rotation", old_rotation, 0.12)
	await tween.finished
	control.pivot_offset = old_pivot
