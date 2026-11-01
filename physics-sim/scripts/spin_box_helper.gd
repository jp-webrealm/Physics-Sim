## makes a spinbox select its whole value when clicked or tabbed into,
## so typing replaces the number instead of adding to it
class_name SpinBoxHelper


static func select_all_on_focus(spin: SpinBox) -> void:
	var line := spin.get_line_edit()
	var just_focused := [false]
	line.focus_entered.connect(func() -> void:
		just_focused[0] = true
		line.select_all.call_deferred())
	# the click that gives focus also places the caret and clears the selection,
	# so select again once that click is released
	line.gui_input.connect(func(event: InputEvent) -> void:
		if just_focused[0] and event is InputEventMouseButton \
				and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			just_focused[0] = false
			line.select_all())
	line.focus_exited.connect(func() -> void: just_focused[0] = false)
