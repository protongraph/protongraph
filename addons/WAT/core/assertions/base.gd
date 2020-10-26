extends Reference

const TYPES = preload("constants/type_library.gd")
var success: bool
var expected: String = "NULL"
var result: String
var notes: String = "No Notes"
var context

func type2str(value):
	return TYPES.get_type_string(typeof(value))
	
func to_dictionary() -> Dictionary:
	return { 
			 "success": success, 
			 "expected": expected, 
			 "actual": result, 
			 "context": context
			}
