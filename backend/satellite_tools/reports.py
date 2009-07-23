
import os

REPORT_DEFINITIONS = "/usr/share/spacewalk/reports/data"

class report:
	def __init__(self, name):
		full_path = os.path.join(REPORT_DEFINITIONS, name)
		fd = open(full_path, 'r')
		self.sql = fd.read()

