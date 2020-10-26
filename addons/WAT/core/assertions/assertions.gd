extends "class_list.gd"

signal OUTPUT
signal asserted

func output(data) -> void:
	emit_signal("asserted", data)

func loop(method: String, data: Array) -> void:
	for set in data:
		callv(method, set)

func is_true(condition: bool, context: String = "") -> void:
	output(IsTrue.new(condition, context))

func is_false(condition: bool, context: String = "") -> void:
	output(IsFalse.new(condition, context))

func is_equal(a, b, context: String = "") -> void:
	output(IsEqual.new(a, b, context))

func is_not_equal(a, b, context: String = "") -> void:
	output(IsNotEqual.new(a, b, context))

func is_greater_than(a, b, context: String = "") -> void:
	output(IsGreaterThan.new(a, b, context))

func is_less_than(a, b, context: String = "") -> void:
	output(IsLessThan.new(a, b, context))

func is_equal_or_greater_than(a, b, context: String = "") -> void:
	output(IsEqualOrGreaterThan.new(a, b, context))

func is_equal_or_less_than(a, b, context: String = "") -> void:
	output(IsEqualOrLessThan.new(a, b, context))

func is_in_range(value, low, high, context: String = "") -> void:
	output(IsInRange.new(value, low, high, context))

func is_not_in_range(value, low, high, context: String = "") -> void:
	output(IsNotInRange.new(value, low, high, context))

func has(value, container, context: String = "") -> void:
	output(Has.new(value, container, context))

func does_not_have(value, container, context: String = "") -> void:
	output(DoesNotHave.new(value, container, context))

func is_class_instance(instance, type, context: String = "") -> void:
	output(IsClassInstance.new(instance, type, context))

func is_not_class_instance(instance, type, context: String = "") -> void:
	output(IsNotClassInstance.new(instance, type, context))

func is_built_in_type(value, type, context: String = "") -> void:
	print("WARNING: is_built_in_type is deprecated. Use is_x where x is builtin type")
	output(IsBuiltInType.new(value, type, context))

func is_not_built_in_type(value, type: int, context: String = "") -> void:
	output(IsNotBuiltInType.new(value, type, context))

func is_null(value, context: String = "") -> void:
	output(IsNull.new(value, context))

func is_not_null(value, context: String = "") -> void:
	output(IsNotNull.new(value, context))

func string_contains(value, string: String, context: String = "") -> void:
	output(Contains.new(value, string, context))

func string_does_not_contain(value, string: String, context: String = "") -> void:
	output(DoesNotContain.new(value, string, context))

func string_begins_with(value, string: String, context: String = "") -> void:
	output(BeginsWith.new(value, string, context))

func string_does_not_begin_with(value, string: String, context: String = "") -> void:
	output(DoesNotBeginWith.new(value, string, context))

func string_ends_with(value, string: String, context: String = "") -> void:
	output(EndsWith.new(value, string, context))

func string_does_not_end_with(value, string: String, context: String = "") -> void:
	output(DoesNotEndWith.new(value, string, context))

func was_called(double, method: String, context: String = "") -> void:
	output(ScriptWasCalled.new(double, method, context))

func was_not_called(double, method: String, context: String = "") -> void:
	output(ScriptWasNotCalled.new(double, method, context))

func was_called_with_arguments(double, method: String, arguments: Array, context: String = "") -> void:
	output(CalledWithArguments.new(double, method, arguments, context))

func signal_was_emitted(emitter, _signal, context: String = "") -> void:
	output(WasEmitted.new(emitter, _signal, context))
	
func signal_was_emitted_x_times(emitter, _signal, times: int, context: String = "") -> void:
	output(WasEmittedXTimes.new(emitter, _signal, times, context))

func signal_was_not_emitted(emitter, _signal: String, context: String = "") -> void:
	output(WasNotEmitted.new(emitter, _signal, context))

func signal_was_emitted_with_arguments(emitter, _signal, arguments: Array, context: String = "") -> void:
	output(WasEmittedWithArguments.new(emitter, _signal, arguments, context))

func file_exists(path: String, context: String = "") -> void:
	output(FileExists.new(path, context))

func file_does_not_exist(path: String, context: String = "") -> void:
	output(FileDoesNotExist.new(path, context))
	
func that(obj: Object, method: String, arguments: Array = [], context: String = "", passed: String = "", failed: String = "") -> void:
	output(That.new(obj, method, arguments, context, passed, failed))
	 
func object_has_meta(obj: Object, meta: String, context: String) -> void:
	output(ObjectHasMeta.new(obj, meta, context))
	
func object_does_not_have_meta(obj: Object, meta: String, context: String) -> void:
	output(ObjectDoesNotHaveMeta.new(obj, meta, context))
	
func object_has_method(obj: Object, method: String, context: String) -> void:
	output(ObjectHasMethod.new(obj, method, context))
	
func object_does_not_have_method(obj: Object, method: String, context: String) -> void:
	output(ObjectDoesNotHaveMethod.new(obj, method, context))
	
func object_is_queued_for_deletion(obj: Object, context: String) -> void:
	output(ObjectIsQueuedForDeletion.new(obj, context))
	
func object_is_not_queued_for_deletion(obj: Object, context: String) -> void:
	output(ObjectIsNotQueuedForDeletion.new(obj, context))
	
func object_is_connected(sender: Object, _signal: String, receiver: Object, method: String, context: String) -> void:
	output(ObjectIsConnected.new(sender, _signal, receiver, method, context))
	
func object_is_not_connected(sender: Object, _signal: String, receiver: Object, method: String, context: String) -> void:
	output(ObjectIsNotConnected.new(sender, _signal, receiver, method, context))
	
func object_is_blocking_signals(obj: Object, context: String) -> void:
	output(ObjectIsBlockingSignals.new(obj, context))
	
func object_is_not_blocking_signals(obj: Object, context: String) -> void:
	output(ObjectIsNotBlockingSignals.new(obj, context))
	
func object_has_user_signal(obj: Object, _signal: String, context: String) -> void:
	output(ObjectHasUserSignal.new(obj, _signal, context))
	
func object_does_not_have_user_signal(obj: Object, _signal: String, context: String) -> void:
	output(ObjectDoesNotHaveUserSignal.new(obj, _signal, context))
	
func is_freed(obj: Object, context: String = "") -> void:
	output(ObjectIsFreed.new(obj, context))

func is_not_freed(obj: Object, context: String = "") -> void:
	output(ObjectIsNotFreed.new(obj, context))

func is_bool(value, context: String = "") -> void:
		output(IsBool.new(value, context))

func is_not_bool(value, context: String = "") -> void:
		output(IsNotBool.new(value, context))

func is_int(value, context: String = "") -> void:
		output(IsInt.new(value, context))

func is_not_int(value, context: String = "") -> void:
		output(IsNotInt.new(value, context))

func is_float(value, context: String = "") -> void:
		output(IsFloat.new(value, context))

func is_not_float(value, context: String = "") -> void:
		output(IsNotFloat.new(value, context))

func is_String(value, context: String = "") -> void:
		output(IsString.new(value, context))

func is_not_String(value, context: String = "") -> void:
		output(IsNotString.new(value, context))

func is_Vector2(value, context: String = "") -> void:
		output(IsVector2.new(value, context))

func is_not_Vector2(value, context: String = "") -> void:
		output(IsNotVector2.new(value, context))

func is_Rect2(value, context: String = "") -> void:
		output(IsRect2.new(value, context))

func is_not_Rect2(value, context: String = "") -> void:
		output(IsNotRect2.new(value, context))

func is_Vector3(value, context: String = "") -> void:
		output(IsVector3.new(value, context))

func is_not_Vector3(value, context: String = "") -> void:
		output(IsNotVector3.new(value, context))

func is_Transform2D(value, context: String = "") -> void:
		output(IsTransform2D.new(value, context))

func is_not_Transform2D(value, context: String = "") -> void:
		output(IsNotTransform2D.new(value, context))

func is_Plane(value, context: String = "") -> void:
		output(IsPlane.new(value, context))

func is_not_Plane(value, context: String = "") -> void:
		output(IsNotPlane.new(value, context))

func is_Quat(value, context: String = "") -> void:
		output(IsQuat.new(value, context))

func is_not_Quat(value, context: String = "") -> void:
		output(IsNotQuat.new(value, context))

func is_AABB(value, context: String = "") -> void:
		output(IsAABB.new(value, context))

func is_not_AABB(value, context: String = "") -> void:
		output(IsNotAABB.new(value, context))

func is_Basis(value, context: String = "") -> void:
		output(IsBasis.new(value, context))

func is_not_Basis(value, context: String = "") -> void:
		output(IsNotBasis.new(value, context))

func is_Transform(value, context: String = "") -> void:
		output(IsTransform.new(value, context))

func is_not_Transform(value, context: String = "") -> void:
		output(IsNotTransform.new(value, context))

func is_Color(value, context: String = "") -> void:
		output(IsColor.new(value, context))

func is_not_Color(value, context: String = "") -> void:
		output(IsNotColor.new(value, context))

func is_NodePath(value, context: String = "") -> void:
		output(IsNodePath.new(value, context))

func is_not_NodePath(value, context: String = "") -> void:
		output(IsNotNodePath.new(value, context))

func is_RID(value, context: String = "") -> void:
		output(IsRID.new(value, context))

func is_not_RID(value, context: String = "") -> void:
		output(IsNotRID.new(value, context))

func is_Object(value, context: String = "") -> void:
		output(IsObject.new(value, context))

func is_not_Object(value, context: String = "") -> void:
		output(IsNotObject.new(value, context))

func is_Dictionary(value, context: String = "") -> void:
		output(IsDictionary.new(value, context))

func is_not_Dictionary(value, context: String = "") -> void:
		output(IsNotDictionary.new(value, context))

func is_Array(value, context: String = "") -> void:
		output(IsArray.new(value, context))

func is_not_Array(value, context: String = "") -> void:
		output(IsNotArray.new(value, context))

func is_PoolByteArray(value, context: String = "") -> void:
		output(IsPoolByteArray.new(value, context))

func is_not_PoolByteArray(value, context: String = "") -> void:
		output(IsNotPoolByteArray.new(value, context))

func is_PoolIntArray(value, context: String = "") -> void:
		output(IsPoolIntArray.new(value, context))

func is_not_PoolIntArray(value, context: String = "") -> void:
		output(IsNotPoolIntArray.new(value, context))

func is_PoolRealArray(value, context: String = "") -> void:
		output(IsPoolRealArray.new(value, context))

func is_not_PoolRealArray(value, context: String = "") -> void:
		output(IsNotPoolRealArray.new(value, context))

func is_PoolStringArray(value, context: String = "") -> void:
		output(IsPoolStringArray.new(value, context))

func is_not_PoolStringArray(value, context: String = "") -> void:
		output(IsNotPoolStringArray.new(value, context))

func is_PoolVector2Array(value, context: String = "") -> void:
		output(IsPoolVector2Array.new(value, context))

func is_not_PoolVector2Array(value, context: String = "") -> void:
		output(IsNotPoolVector2Array.new(value, context))

func is_PoolVector3Array(value, context: String = "") -> void:
		output(IsPoolVector3Array.new(value, context))

func is_not_PoolVector3Array(value, context: String = "") -> void:
		output(IsNotPoolVector3Array.new(value, context))

func is_PoolColorArray(value, context: String = "") -> void:
		output(IsPoolColorArray.new(value, context))

func is_not_PoolColorArray(value, context: String = "") -> void:
		output(IsNotPoolColorArray.new(value, context))
		
func fail(context: String = "Unimplemented Test") -> void:
		output(Fail.new(context))
