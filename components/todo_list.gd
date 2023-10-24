extends PanelContainer

@export var input_field: LineEdit
@export var container: VBoxContainer
@export var footer: PanelContainer

const TodoCardScene = preload("res://components/todo_card.tscn")
const ALL_TODOS: int = 1
const ACTIVE_TODOS: int = 2
const COMPLETED_TODOS: int = 3

var filter: int = ALL_TODOS:
	set = set_filter

var todos: Array = []:
	set = set_todos

var todo_card_refs: Array = []


func _ready():
	set_todos(Storage.load_todos())
	input_field.text_submitted.connect(_handle_submit)
	footer.clear_completed_requested.connect(_clear_completed)
	footer.filter_changed.connect(set_filter)

func set_filter(value: int):
	filter = clamp(value, 1, 3)
	_on_filter_changed()

func set_todos(new_todos: Array):
	todos = new_todos
	_on_todos_changed()

func add_todo(value: String):
	set_todos(todos + [{
		id = Storage.get_next_id(),
		value = value,
		is_completed = false
	}])

func _on_todos_changed():
	Storage.save_todos(todos)
	_render_todos()
	_update_footer()

func _on_filter_changed():
	_render_todos()
	_update_footer()

func _handle_submit(value: String):
	if not value:
		return
	
	add_todo(value)
	input_field.clear()

func _update_footer():
	if not todos.size():
		footer.hide()
		return
	
	footer.update(
		_get_active_todos_count(),
		_get_completed_todos_count(),
		filter
	)

func _clear_completed():
	set_todos(todos.filter(func(todo):
		return not todo.is_completed
	))

func _toggle_completed(id: int):
	set_todos(todos.map(func(todo):
		if todo.id != id:
			return todo
		
		var new_todo: Dictionary = todo.duplicate()
		new_todo.is_completed = not todo.is_completed
		return new_todo
	))

func _delete_todo(id: int):
	set_todos(todos.filter(func(todo): return todo.id != id))

func _update_task(id: int, value: String):
	if not value:
		_delete_todo(id)
		return
	
	set_todos(todos.map(func(todo):
		if todo.id != id:
			return todo
		
		var new_todo: Dictionary = todo.duplicate()
		new_todo.value = value
		return new_todo
	))

func _get_active_todos_count() -> int:
	return todos.filter(func(todo): return not todo.is_completed).size()

func _get_completed_todos_count() -> int:
	return todos.filter(func(todo): return todo.is_completed).size()

func _render_todos():
	var todos_to_render: Array = []
	
	match filter:
		ALL_TODOS:
			todos_to_render = todos
		ACTIVE_TODOS:
			todos_to_render = todos.filter(func(todo): return not todo.is_completed)
		COMPLETED_TODOS:
			todos_to_render = todos.filter(func(todo): return todo.is_completed)
		_:
			todos_to_render = todos
	
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		
	todos_to_render.map(func(todo):
		var card = TodoCardScene.instantiate()
		card.set_todo(todo)
		card.completed_toggled.connect(_toggle_completed.bind(todo.id))
		card.remove_pressed.connect(_delete_todo.bind(todo.id))
		card.task_changed.connect(func(value): _update_task(todo.id, value))

		container.add_child(card)
	)
