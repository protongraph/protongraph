extends Resource
tool
# Dictionary's cannot take type hints.
# The keys are test scripts
# The values are an array of tags
#export(Dictionary) var index = {}

# Seems we cannot cache scripts properly without hints
# so we'll have to use some indexing magic for this
export(Array, Script) var scripts: Array = []
export(Array, Array, String) var tags: Array = []
