## Right-edge menu button that slides the build controls in and out.
extends Control

## keeps the menu inside the walls so the rulers on them stay visible
const MARGIN := 64.0
const PANEL_WIDTH := 340.0
const BUTTON_WIDTH := 88.0
## matches the start simulation button so the two top corners line up
const BUTTON_HEIGHT := 44.0
const HIDDEN_PUSH := 40.0
const SLIDE_TIME := 0.2

const TEXT_COLOR := Color(0.92, 0.92, 0.92)
const MUTED_TEXT := Color(0.6, 0.6, 0.6)
const PANEL_COLOR := Color(0.04, 0.04, 0.04, 0.97)
const BORDER_COLOR := Color(0.2, 0.2, 0.2)
const BUTTON_COLOR := Color(0.22, 0.22, 0.22)
const BUTTON_HOVER := Color(0.28, 0.28, 0.28)
const BUTTON_PRESSED := Color(0.17, 0.17, 0.17)

@onready var panel: PanelContainer = $Panel
@onready var toggle_button: Button = $Toggle

var _open := false
var _slide := 0.0
var _tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wire_gameplay_refs()
	_apply_theme()
	_place_button()
	_apply_slide(0.0)
	toggle_button.pressed.connect(toggle)
	_connect_start_button()

func toggle() -> void:
	_open = not _open
	toggle_button.text = "Close" if _open else "Menu"
	toggle_button.tooltip_text = "Hide controls" if _open else "Show controls"
	_animate_to(1.0 if _open else 0.0)

func _wire_gameplay_refs() -> void:
	%SquareSlot.settings = %RectSettings
	%CircleSlot.settings = %CircleSettings
	%SpringSlot.elasticity_slider = %ElasticitySlider
	%ElasticitySlider.value_changed.connect(func(value: float) -> void:
		%ElasticityValue.text = str(int(value)))
	%ElasticityValue.text = str(int(%ElasticitySlider.value))
	var spawned := get_node_or_null("../../spawned shapes") as Node2D
	if spawned:
		for slot in [%JointSlot, %HingeSlot, %SpringSlot]:
			slot.spawn_parent = spawned
	else:
		push_error("Side menu could not find spawned shapes")
	var drop := get_node_or_null("../shape drop area")
	if drop:
		drop.settings = %RectSettings
		drop.materials = %Materials

func _connect_start_button() -> void:
	var start_button := get_node_or_null("../start button") as Button
	if start_button == null:
		return
	start_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_paint_button(start_button)
	var reset_button := get_node_or_null("../reset button") as Button
	if reset_button:
		reset_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_paint_button(reset_button)

func _place_button() -> void:
	toggle_button.anchor_left = 1.0
	toggle_button.anchor_top = 0.0
	toggle_button.anchor_right = 1.0
	toggle_button.anchor_bottom = 0.0
	toggle_button.offset_left = -(MARGIN + BUTTON_WIDTH)
	toggle_button.offset_top = MARGIN
	toggle_button.offset_right = -MARGIN
	toggle_button.offset_bottom = MARGIN + BUTTON_HEIGHT
	toggle_button.z_index = 2
	toggle_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _animate_to(target: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_method(_apply_slide, _slide, target, SLIDE_TIME)

func _apply_slide(t: float) -> void:
	_slide = clampf(t, 0.0, 1.0)
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_top = MARGIN
	panel.offset_bottom = -MARGIN
	var open_right := -MARGIN
	var closed_right := HIDDEN_PUSH + PANEL_WIDTH
	var right := lerpf(closed_right, open_right, _slide)
	panel.offset_right = right
	panel.offset_left = right - PANEL_WIDTH

func _apply_theme() -> void:
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	panel.z_index = 1
	var theme := Theme.new()
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		theme.set_color(color_name, "CheckButton", TEXT_COLOR)
	theme.set_color("font_color", "Label", TEXT_COLOR)
	theme.set_font_size("font_size", "CheckButton", 15)
	panel.theme = theme
	_paint_button(toggle_button)
	_style_header(%TitleLabel, 20)
	_style_header(%ToolsLabel, 16)
	_style_header(%RectLabel, 16)
	_style_header(%CircleLabel, 16)
	_style_header(%SpringLabel, 16)
	_style_header(%SurfaceLabel, 16)
	var slot_style := _make_slot_style()
	for node in get_tree().get_nodes_in_group("tool_slot"):
		if node is PanelContainer:
			node.add_theme_stylebox_override("panel", slot_style)
			node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for node in get_tree().get_nodes_in_group("tool_caption"):
		if node is Label:
			node.add_theme_font_size_override("font_size", 12)
			node.add_theme_color_override("font_color", MUTED_TEXT)
	for slot in [%SquareSlot, %CircleSlot, %JointSlot, %HingeSlot, %SpringSlot]:
		slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var line := StyleBoxLine.new()
	line.color = BORDER_COLOR
	line.thickness = 1
	_style_separators(panel, line)

func _style_separators(node: Node, line: StyleBoxLine) -> void:
	for child in node.get_children():
		if child is HSeparator:
			child.add_theme_stylebox_override("separator", line)
		_style_separators(child, line)

func _style_header(label: Label, size: int) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT_COLOR)

func _paint_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(BUTTON_COLOR))
	button.add_theme_stylebox_override("hover", _make_button_style(BUTTON_HOVER))
	button.add_theme_stylebox_override("pressed", _make_button_style(BUTTON_PRESSED))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(color_name, TEXT_COLOR)
	button.add_theme_font_size_override("font_size", 15)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(16)
	# the header row starts flush with the top so the title lines up with the menu button
	style.content_margin_top = 0
	return style

func _make_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

func _make_slot_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = BUTTON_COLOR
	style.set_corner_radius_all(10)
	style.set_content_margin_all(6)
	return style
