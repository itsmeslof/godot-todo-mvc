extends Control

signal completed_toggled
signal remove_pressed
signal task_changed(value)

@export var checkbox: CheckBox
@export var label: Label
@export var remove_btn: TextureButton
@export var edit_field: LineEdit

var is_editing: bool = false:
	set = set_is_editing

var active_text_color: Color = Color("#4D4D4D")
var completed_text_color: Color = Color("#D9D9D9")

var todo: Dictionary = {}:
	set = set_todo

func _ready():
	label.gui_input.connect(_handle_label_gui_input)
	mouse_entered.connect(func():
		if is_editing:
			return
		
		remove_btn.show()
	)
	mouse_exited.connect(remove_btn.hide)
	checkbox.toggled.connect(_toggle_completed)
	remove_btn.pressed.connect(func(): remove_pressed.emit())
	edit_field.text_submitted.connect(_update_task)
	edit_field.focus_exited.connect(set_is_editing.bind(false))
	edit_field.gui_input.connect(func(ev):
		if not ev is InputEventKey:
			return
		
		ev = ev as InputEventKey
		if ev.get_keycode() == KEY_ESCAPE and ev.is_pressed():
			print("escape pressed, resetting state")
			set_is_editing(false)
	)
	_render()

func set_todo(new_todo: Dictionary):
	todo = new_todo
	_render()

func set_is_editing(value: bool):
	is_editing = value
	edit_field.clear()
	_render()

func _update_task(new_text: String):
	is_editing = false
	task_changed.emit(new_text)

func _toggle_completed(completed):
	completed_toggled.emit()

func _handle_label_gui_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	
	event = event as InputEventMouseButton
	if not event.is_pressed():
		return
	
	if event.is_double_click():
		is_editing = true

func _render():
	if not todo:
		return
	
	label.text = todo.value
	label.add_theme_color_override(
		"font_color",
		completed_text_color if todo.is_completed else active_text_color
	)
	
	checkbox.set_pressed_no_signal(todo.is_completed)
	
	if not is_editing:
		if edit_field.has_focus():
			edit_field.release_focus()
		edit_field.hide()
		label.show()
		return
	else:
		remove_btn.hide()
		label.hide()
		edit_field.show()
		edit_field.set_text(todo.value)
		edit_field.grab_focus()
		edit_field.caret_column = edit_field.text.length()
