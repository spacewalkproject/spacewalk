import unittest
import test_server

def testSuite():
	suite = unittest.TestSuite()
	loader = unittest.TestLoader()
	
	"""
	def testModule(module):
		import module
		suite.addTests(loader.loadTestsFromModule(module))
	
	"""
	suite.addTest(loader.loadTestsFromModule(test_server))
	return suite

if __name__ == "__main__":
	unittest.main(defaultTest = "testSuite")
