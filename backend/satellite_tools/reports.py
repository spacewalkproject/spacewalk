
import os

REPORT_DEFINITIONS = "/usr/share/spacewalk/reports/data"

def available_reports():
	return os.listdir(REPORT_DEFINITIONS)

class report:
	def __init__(self, name):
		full_path = os.path.join(REPORT_DEFINITIONS, name)
		fd = open(full_path, 'r')
		self.sql = fd.read()

