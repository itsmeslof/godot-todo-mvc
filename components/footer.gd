extends PanelContainer

signal filter_changed(new_filter: int)
signal clear_completed_requested()

@export var count_label: Label
@export var clear_completed_btn: LinkButton
@export var all_btn: Button
@export var active_btn: Button
@export var completed_btn: Button

var active_count: int = 0
var completed_count: int = 0
var filter: int = 1

func _ready():
	clear_completed_btn.pressed.connect(func(): clear_completed_requested.emit())
	all_btn.pressed.connect(func(): filter_changed.emit(1))
	active_btn.pressed.connect(func(): filter_changed.emit(2))
	completed_btn.pressed.connect(func(): filter_changed.emit(3))

func update(new_active_count: int, new_completed_count: int, new_filter: int):
	active_count = new_active_count
	completed_count = new_completed_count
	filter = new_filter
	_render()

func _render():
	show()
	
	count_label.text = "%s %s left" % [active_count, "item" if active_count == 1 else "items"]
	
	all_btn.disabled = filter == 1
	active_btn.disabled = filter == 2
	completed_btn.disabled = filter == 3
	
	clear_completed_btn.visible = completed_count > 0
