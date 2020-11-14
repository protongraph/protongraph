extends Reference

# Boolean Assertions
const IsFalse: Script = preload("boolean/is_false.gd")
const IsTrue: Script = preload("boolean/is_true.gd")

# Test Double Assertions
const CalledWithArguments: Script = preload("double/called_with_arguments.gd")
const ScriptWasCalled: Script = preload("double/script_was_called.gd")
const ScriptWasNotCalled: Script = preload("double/script_was_not_called.gd")

# Equality Assertions
const IsEqual: Script = preload("equality/is_equal.gd")
const IsEqualOrGreaterThan: Script = preload("equality/is_equal_or_greater_than.gd")
const IsEqualOrLessThan: Script = preload("equality/is_equal_or_less_than.gd")
const IsGreaterThan: Script = preload("equality/is_greater_than.gd")
const IsLessThan: Script = preload("equality/is_less_than.gd")
const IsNotEqual: Script = preload("equality/is_not_equal.gd")

# File Assertions
const FileDoesNotExist: Script = preload("file/file_does_not_exist.gd")
const FileExists: Script = preload("file/file_exists.gd")

# Is <TYPE> Assertions
const IsAABB: Script = preload("is/is_AABB.gd")
const IsArray: Script = preload("is/is_Array.gd")
const IsBasis: Script = preload("is/is_Basis.gd")
const IsBool: Script = preload("is/is_bool.gd")
const IsBuiltInType: Script = preload("is/is_built_in_type.gd")
const IsClassInstance: Script = preload("is/is_class_instance.gd")
const IsColor: Script = preload("is/is_Color.gd")
const IsDictionary: Script = preload("is/is_Dictionary.gd")
const IsFloat: Script = preload("is/is_float.gd")
const IsInt: Script = preload("is/is_int.gd")
const IsNodePath: Script = preload("is/is_NodePath.gd")
const IsObject: Script = preload("is/is_Object.gd")
const IsPlane: Script = preload("is/is_Plane.gd")
const IsPoolByteArray: Script = preload("is/is_PoolByteArray.gd")
const IsPoolColorArray: Script = preload("is/is_PoolColorArray.gd")
const IsPoolIntArray: Script = preload("is/is_PoolIntArray.gd")
const IsPoolRealArray: Script = preload("is/is_PoolRealArray.gd")
const IsPoolStringArray: Script = preload("is/is_PoolStringArray.gd")
const IsPoolVector2Array: Script = preload("is/is_PoolVector2Array.gd")
const IsPoolVector3Array: Script = preload("is/is_PoolVector3Array.gd")
const IsQuat: Script = preload("is/is_Quat.gd")
const IsRect2: Script = preload("is/is_Rect2.gd")
const IsRID: Script = preload("is/is_RID.gd")
const IsString: Script = preload("is/is_String.gd")
const IsTransform: Script = preload("is/is_Transform.gd")
const IsTransform2D: Script = preload("is/is_Transform2D.gd")
const IsVector2: Script = preload("is/is_Vector2.gd")
const IsVector3: Script = preload("is/is_Vector3.gd")

# Is Not <TYPE> Assertions
const IsNotAABB: Script = preload("is_not/is_not_AABB.gd")
const IsNotArray: Script = preload("is_not/is_not_Array.gd")
const IsNotBasis: Script = preload("is_not/is_not_Basis.gd")
const IsNotBool: Script = preload("is_not/is_not_bool.gd")
const IsNotBuiltInType: Script = preload("is_not/is_not_built_in_type.gd")
const IsNotClassInstance: Script = preload("is_not/is_not_class_instance.gd")
const IsNotColor: Script = preload("is_not/is_not_Color.gd")
const IsNotDictionary: Script = preload("is_not/is_not_Dictionary.gd")
const IsNotFloat: Script = preload("is_not/is_not_float.gd")
const IsNotInt: Script = preload("is_not/is_not_int.gd")
const IsNotNodePath: Script = preload("is_not/is_not_NodePath.gd")
const IsNotObject: Script = preload("is_not/is_not_Object.gd")
const IsNotPlane: Script = preload("is_not/is_not_Plane.gd")
const IsNotPoolByteArray: Script = preload("is_not/is_not_PoolByteArray.gd")
const IsNotPoolColorArray: Script = preload("is_not/is_not_PoolColorArray.gd")
const IsNotPoolIntArray: Script = preload("is_not/is_not_PoolIntArray.gd")
const IsNotPoolRealArray: Script = preload("is_not/is_not_PoolRealArray.gd")
const IsNotPoolStringArray: Script = preload("is_not/is_not_PoolStringArray.gd")
const IsNotPoolVector2Array: Script = preload("is_not/is_not_PoolVector2Array.gd")
const IsNotPoolVector3Array: Script = preload("is_not/is_not_PoolVector3Array.gd")
const IsNotQuat: Script = preload("is_not/is_not_Quat.gd")
const IsNotRect2: Script = preload("is_not/is_not_Rect2.gd")
const IsNotRID: Script = preload("is_not/is_not_RID.gd")
const IsNotString: Script = preload("is_not/is_not_String.gd")
const IsNotTransform: Script = preload("is_not/is_not_Transform.gd")
const IsNotTransform2D: Script = preload("is_not/is_not_Transform2D.gd")
const IsNotVector2: Script = preload("is_not/is_not_Vector2.gd")
const IsNotVector3: Script = preload("is_not/is_not_Vector3.gd")

# Null Assertions
const IsNull: Script = preload("null/is_null.gd")
const IsNotNull: Script = preload("null/is_not_null.gd")

# Object Assertions
# Note: The elements this assertions act on exist throughout every object
# ..in godot so it was necessary. For other class-specific assertions..
# users should use assert.that
const ObjectIsFreed: Script = preload("object/is_freed.gd")
const ObjectIsNotFreed: Script = preload("object/is_not_freed.gd")
const ObjectHasMeta: Script = preload("object/has_meta.gd")
const ObjectDoesNotHaveMeta: Script = preload("object/does_not_have_meta.gd")
const ObjectHasMethod: Script = preload("object/has_method.gd")
const ObjectDoesNotHaveMethod: Script = preload("object/does_not_have_method.gd")
const ObjectHasUserSignal: Script = preload("object/has_user_signal.gd")
const ObjectDoesNotHaveUserSignal: Script = preload("object/does_not_have_user_signal.gd")

const ObjectIsQueuedForDeletion: Script = preload("object/is_queued_for_deletion.gd")
const ObjectIsNotQueuedForDeletion: Script = preload("object/is_not_queued_for_deletion.gd")
const ObjectIsBlockingSignals: Script = preload("object/is_blocking_signals.gd")
const ObjectIsNotBlockingSignals: Script = preload("object/is_not_blocking_signals.gd")
const ObjectIsConnected: Script = preload("object/is_connected.gd")
const ObjectIsNotConnected: Script = preload("object/is_not_connected.gd")

# Property Assertions
const Has: Script = preload("property/has.gd")
const DoesNotHave: Script = preload("property/does_not_have.gd")

# Range Assertions
const IsInRange: Script = preload("range/is_in_range.gd")
const IsNotInRange: Script = preload("range/is_not_in_range.gd")

# Signal Assertions
const WasEmitted: Script = preload("signal/signal_was_emitted.gd")
const WasEmittedXTimes: Script = preload("signal/signal_was_emitted_x_times.gd")
const WasEmittedWithArguments: Script = preload("signal/signal_was_emitted_with_arguments.gd")
const WasNotEmitted: Script = preload("signal/signal_was_not_emitted.gd")

# String Assertions
const BeginsWith: Script = preload("string/string_begins_with.gd")
const Contains: Script = preload("string/string_contains.gd")
const DoesNotBeginWith: Script = preload("string/string_does_not_begin_with.gd")
const DoesNotContain: Script = preload("string/string_does_not_contain.gd")
const DoesNotEndWith: Script = preload("string/string_does_not_end_with.gd")
const EndsWith: Script = preload("string/string_ends_with.gd")

# Misc Utility Assertions
const That: Script = preload("misc/that.gd")
const Fail: Script = preload("misc/fail.gd")
