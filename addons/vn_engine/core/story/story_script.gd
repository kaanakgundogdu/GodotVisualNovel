extends Resource
class_name StoryScript


@export var source_path: String = ""
@export var chapter_id: String = ""
@export var nodes: Array[StoryNode] = []
@export var labels: Dictionary = {}
@export var diagnostics: Array[ParseDiagnostic] = []

func has_errors() -> bool:
	for diag in diagnostics:
		if diag.severity == ParseDiagnostic.Severity.ERROR:
			return true
	return false

func index_of(target: String) -> int:
	if labels.has(target):
		return labels[target]
	return -1
