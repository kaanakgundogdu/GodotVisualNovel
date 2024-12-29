class_name DialogUtils

func strip_bbcode(bbcode_str: String) -> String:
	var result = ""
	var inside_tag = false
	for c in bbcode_str:
		if c == "[":
			inside_tag = true
		elif c == "]":
			inside_tag = false
		elif not inside_tag:
			result += c
	return result
