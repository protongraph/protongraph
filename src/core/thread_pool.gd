tool
extends Reference
class_name ConceptGraphThreadPool

"""
WARNING : Don't use this yet.

An barebone thread pool specifically made for the ConceptGraph addon. There's no need for
synchronization between threads, no parameters or no return data.
"""


signal task_completed
signal all_tasks_completed

var locked := true
var _max_threads := OS.get_processor_count() - 1	# Minus 1 because the main thread already use one core
var _available_threads := []
var _busy_threads := []
var _queue := []
var _queue_mutex := Mutex.new()


func _init() -> void:
	for i in _max_threads:
		_available_threads.append(Thread.new())
	Signals.safe_connect(self, "task_completed", self, "_on_task_completed")


"""
Call this to submit a function to run to the thread pool. If a thread is available it will be
processed immediately. If not, it will be put in a queue and be processed when a thread is available
"""
func submit_task(node, function) -> void:
	if _available_threads.size() > 0:
		var thread = _available_threads.pop_front()
		#("Available thread ", thread, " will execute ", node.display_name, " task ", node.get_name())
		thread.start(self, "_run_task", [node, function, thread])
		_busy_threads.push_back(thread)
	else:
		#print("No thread available, queueing ", node.display_name, " task")
		_queue.push_back({"node": node, "function": function})

"""
Call this to cancel all pending tasks. Returns true if no thread is busy, false otherwise
"""
func cancel_all() -> bool:
	_queue_mutex.lock()
	_queue = []
	_queue_mutex.unlock()

	if _busy_threads.size() == 0:
		return true

	return false


"""
This is the function ran in the background. We don't call thread.start directly on the
user-provided function so we can emit a signal at the end to notify the thread is available again.
"""
func _run_task(arg) -> void:
	var node = arg[0]
	var function = arg[1]
	var thread = arg[2]
	node.call(function)
	call_deferred("emit_signal", "task_completed", thread)


"""
Called when a thread finishes its current task. If there are pending task in the queue, pick one,
otherwise move the thread to the available pool.
"""
func _on_task_completed(thread) -> void:
	#("Thread ", thread, " completed its task")
	thread.wait_to_finish()

	_queue_mutex.lock()
	if _queue.size() > 0:
		var task = _queue.pop_front()
		#("Queued task available, starting ", task["node"].display_name, " on thread ", thread)
		thread.start(self, "_run_task", [task["node"], task["function"], thread])
	else:
		#print("No tasks queued, moving thread ", thread, " to the available thread pool")
		_busy_threads.erase(thread)
		_available_threads.append(thread)
		if _busy_threads.size() == 0:
			emit_signal("all_tasks_completed")
	_queue_mutex.unlock()
