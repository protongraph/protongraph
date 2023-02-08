class_name EventBus
extends Node

# Declare every signal sent on any event bus here.
#
# Naming conventions:
# - End with a verb in past tense for events that already happened
# - Start with a verb in present tense for intents (commands)
# - Alphabetically ordered


signal browse_examples
signal create_graph
signal current_view_changed
signal file_history_changed
signal graph_loaded(NodeGraph)
signal graph_saved(NodeGraph)
signal load_graph
signal open_settings
signal quit
signal remove_from_file_history
signal settings_updated
signal save_all
signal save_graph_as
signal save_graph
signal save_status_updated(String)
signal show_on_viewport(id: String, data: Array)
