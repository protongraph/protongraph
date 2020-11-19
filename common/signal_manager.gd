extends Object
class_name SignalManager

# Declare every signal sent on any event bus here. This will be used by
# the EventBus class that needs to know about every possible events in advance.
# 
# Naming conventions:
#  - End with a verb in the past tense for events that happened
#  - Start with a verb in present tense for intents (commands)
# Alphabetically ordered

# warning-ignore-all:UNUSED_SIGNAL
signal build_for_remote
signal create_template
signal file_history_changed
signal load_template
signal message
signal open_remote_view
signal open_settings
signal peer_disconnected
signal peer_connected
signal quit
signal remote_build_started
signal remote_build_completed
signal remove_from_file_history
signal settings_updated
signal save_all_templates
signal save_template_as
signal save_template
signal template_loaded
signal template_saved


func call_emit_signal(args):
	callv("emit_signal", args)

