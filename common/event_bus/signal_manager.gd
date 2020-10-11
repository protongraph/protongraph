extends Object
class_name SignalManager

# Declare every signal sent on any event bus here. This will be used by
# the EventBus class that needs to know about every possible events in advance.
# 
# Naming conventions:
#  - End with a verb in the past tense for events that happened
#  - Start with a verb in present tense for intents (commands)
# Alphabetically ordered

signal create_template
signal load_template
signal message
signal open_settings
signal quit
signal save_all_templates
signal save_template_as
signal save_template
signal template_loaded
signal template_saved
signal generate
signal cleanup


func call_emit_signal(args):
	callv("emit_signal", args)
