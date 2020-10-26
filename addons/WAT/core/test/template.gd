extends WAT.Test

func title():
	return "TEST GROUP NAME"

func start():
	# Runs before all test related methods once
	pass

func pre():
	# Runs before each test method
	pass

func test_METHOD():
	describe("TEST DESCRIPTION")
	# Create one for each test with a relevant name that MUST start with `test_`
	pass

func post():
	# Runs after each test method
	pass

func end():
	# Runs after all other test related methods once
	pass
