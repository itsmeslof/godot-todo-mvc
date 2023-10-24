extends Node

var STORAGE_PATH: String = "%s/data.json" % OS.get_user_data_dir()

var next_id: int = 1
func get_next_id() -> int:
	var _next_id = next_id
	next_id += 1
	return _next_id

func load_todos() -> Array:
	var contents = FileAccess.get_file_as_string(STORAGE_PATH)
	
	# If JSON.parse_string fails, we will validate null and reset automatically
	var data = _validate_data(JSON.parse_string(contents))
	next_id = int(data.get("next_id"))
	return data.get("todos")

func _validate_data(data) -> Dictionary:
	var cleaned_data: Dictionary = {
		next_id = 1,
		todos = []
	}
	
	if not data is Dictionary:
		_reset_data()
		return cleaned_data
	
	data = data as Dictionary
	
	var _next_id = data.get("next_id", null)
	if typeof(_next_id) == TYPE_FLOAT:
		_next_id = int(_next_id)
	var _todos = data.get("todos", [])
	
	if not _todos is Array:
		_reset_data()
		return cleaned_data
	
	var todos: Array = []
	
	_todos.map(func(todo):
		if not todo is Dictionary:
			return
		
		if _is_valid_todo(todo):
			todos.append(todo)
	)
	
	if not _next_id is int:
		_reset_data()
		return cleaned_data
	
	cleaned_data["next_id"] = _next_id
	cleaned_data["todos"] = todos
	return cleaned_data

func _is_valid_todo(todo: Dictionary) -> bool:
	var id = todo.get("id")
	var value = todo.get("value")
	var is_completed = todo.get("is_completed")
	
	if typeof(id) == TYPE_FLOAT:
		id = int(id)
	
	return (
		typeof(id) == TYPE_INT and 
		typeof(value) == TYPE_STRING and len(value) > 0 and 
		typeof(is_completed) == TYPE_BOOL
	)

func save_todos(todos: Array):
	var file: FileAccess = FileAccess.open(STORAGE_PATH, FileAccess.WRITE)
	if not file:
		OS.alert(
			"Unable to access file %s" % STORAGE_PATH,
			"Error saving data"
		)
		return

	var data = {
		next_id = next_id,
		todos = todos
	}
	file.store_string(JSON.stringify(data))

func _validate_todos(todos: Array) -> Array:
	var valid_todos: Array = []

	for todo in todos:
		if not todo is Dictionary:
			continue
		
		todo = todo as Dictionary
	
		if not todo.has_all(['id', 'value', 'completed']):
			continue
		
		valid_todos.append(todo)
	
	return valid_todos

func _reset_data():
	next_id = 1
	save_todos([])
