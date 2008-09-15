import unittest
from config import *

class ApiTests(unittest.TestCase):
    def test_version(self):
        self.assertEquals('5.0.0', client.api.system_version())
        self.assertEquals('5.0.0 Java', client.api.get_version())


if __name__ == "__main__":
    unittest.main()
