tool
extends Control

var test: Resource
const Tag: PackedScene = preload("Tag.tscn")
onready var TagSelector: Control = $Tags/Select.get_popup()
onready var TagList: Control = $TagList
var metadata

func _initalize() -> void:
	var testdir: String = ProjectSettings.get_setting("WAT/Test_Directory")
	var dir: Directory = Directory.new()
#	var config: String = "%s/.test" % testdir
#	if not dir.dir_exists(config):
#		dir.make_dir(config)
	var savepath: String = "res://.test/metadata.tres"
	if not dir.file_exists(savepath):
		var res: Resource = load("res://addons/WAT/ui/metadata/index.gd").new()
		ResourceSaver.save(savepath, res)
		
func set_metadata() -> void:
	_initalize()
	var test_dir: String = ProjectSettings.get_setting("WAT/Test_Directory")
	var savepath: String = "res://.test/metadata.tres"
	metadata = load(savepath)

func global_tags() -> Array:
	# Add this to settings?
	return ProjectSettings.get_setting("WAT/Tags")

func tags() -> Array:
	# May need to add error handling here
	return metadata.tags[id()]
	
func id() -> int:
	# returns position in scripts array
	return metadata.scripts.find(test)
	
func _ready() -> void:
	set_metadata()
	$Data/ClearAll.connect("pressed", self, "_delete_all")
	test = load(test.resource_path) # I think this gives us the binary path?
	if not metadata.scripts.has(test):
		metadata.scripts.append(test)
		metadata.tags.append([])
		save()
	TagSelector.connect("about_to_show", self, "_update_selectable_tags")
	TagSelector.connect("id_pressed", self, "_add_tag")
	
func _delete_all() -> void:
	for child in TagList.get_children():
		delete(child)
	
func populate() -> void:
	for t in tags():
		var tag: Control = Tag.instance()
		TagList.add_child(tag)
		tag.Name.text = t
		tag.Delete.connect("pressed", self, "delete", [tag])
		
func _update_selectable_tags() -> void:
	TagSelector.clear()
	for tag in global_tags():
		if not tag as String in tags():
			TagSelector.add_item(tag)
	TagSelector.update()
			
func _add_tag(id: int) -> void:
	var tagtext: String = TagSelector.get_item_text(id)
	var tag: Control = Tag.instance()
	TagList.add_child(tag)
	tag.Name.text = tagtext
	tag.Delete.connect("pressed", self, "delete", [tag])
	metadata.tags[id()].append(tagtext as String)
	save()
	
func delete(tag: Control) -> void:
	print("deleting")
	TagList.remove_child(tag)
	tag.queue_free()
	metadata.tags[id()].erase(tag.Name.text as String)
	save()

func save() -> void:
	var err = ResourceSaver.save(metadata.resource_path, metadata)
	if err != OK:
		push_warning(err as String)
