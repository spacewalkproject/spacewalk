
import os
import re

REPORT_DEFINITIONS = "/usr/share/spacewalk/reports/data"

def available_reports():
	return os.listdir(REPORT_DEFINITIONS)

class report:
	def __init__(self, name):
		full_path = os.path.join(REPORT_DEFINITIONS, name)
		self.sql = None
		self.columns = None
		self._load(full_path)

	def _load(self, full_path):
		try:
			fd = open(full_path, 'r')
		except (IOError):
			raise spacewalk_unknown_report
		tag = None
		value = ''
		re_comment = re.compile('^\s*#')
		re_tag_name = re.compile('^(\S+):\s*$')

		for line in fd:
			result = re_comment.match(line)
			if result != None:
				continue

			result = re_tag_name.match(line)
			if result != None:
				if tag != None:
					self._set(tag, value)
					tag = None
					value = ''
				tag = result.group(1)
			else:
				value += line

		if tag != None:
			self._set(tag, value)

	def _set(self, tag, value):
		if tag == 'columns':
			self.columns = filter(lambda x: x != '', re.split('\s+', value))
		elif tag == 'sql':
			self.sql = value
		else:
			raise spacewalk_report_unknown_tag_exception(tag)


class spacewalk_unknown_report(Exception):
	pass

class spacewalk_report_unknown_tag_exception(Exception):
	pass

