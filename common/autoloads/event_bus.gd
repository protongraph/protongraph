class_name EventBus
extends Node

# Declare every signal sent on any event bus here.
#
# Naming conventions:
#  - End with a verb in the past tense for events that happened
#  - Start with a verb in present tense for intents (commands)
# Alphabetically ordered


signal create_graph
signal current_view_changed
signal file_history_changed
signal load_graph
signal message
signal open_settings
signal quit
signal remove_from_file_history
signal settings_updated
signal save_all
signal save_graph_as
signal save_graph
signal graph_loaded
signal graph_saved


# warning-ignore-all:UNUSED_SIGNAL
