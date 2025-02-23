extends Node

class_name DialogReader

func get_dialogs(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json_parser = JSON.new()
		var error_code = json_parser.parse(json_string)

		if error_code != OK:
			printerr("Error parsing JSON at line 0: ", json_parser.get_error_message())
			return null
		else:
			print("JSON parsed successfully.")
			var dialogs = json_parser.get_data()["dialogs"]
			return dialogs
	else:
		printerr("Error: Could not open the file. Please check the file path.")

	return null
