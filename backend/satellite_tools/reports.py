
import os
import re

REPORT_DEFINITIONS = "/usr/share/spacewalk/reports/data"

def available_reports():
	return os.listdir(REPORT_DEFINITIONS)

class report:
	def __init__(self, name):
		full_path = os.path.join(REPORT_DEFINITIONS, name)
		self.sql = None
		self.description = None
		self.synopsis = None
		self.columns = None
		self.column_indexes = None
		self.column_descriptions = None
		self.multival_column_names = {}
		self.multival_columns_reverted = {}
		self.multival_columns_stop = []
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

		if self.multival_column_names != None:
			unknown_columns = []

			for c in self.multival_column_names:
				if c in self.column_indexes:
					c_id = self.column_indexes[c]
					v = self.multival_column_names[c]
					if v == None:
						self.multival_columns_stop.append(c_id)
					elif v in self.column_indexes:
						v_id = self.column_indexes[v]
						if v_id in self.multival_columns_reverted:
							self.multival_columns_reverted[v_id].append(c_id)
						else:
							self.multival_columns_reverted[v_id] = [ c_id ]
				else:
					unknown_columns.append(c)
			if len(unknown_columns) > 0:
				raise spacewalk_report_unknown_multival_column_exception(unknown_columns)


	def _set(self, tag, value):
		if tag == 'columns':
			self.columns = []
			self.column_indexes = {}
			self.column_descriptions = {}
			lines = filter(lambda x: x != '', re.split('\s*\n\s*', value))
			i = 0
			for l in lines:
				description = None
				try:
					( c, description ) = re.split('\s+', l, 1)
				except:
					c = l
				self.columns.append(c)
				self.column_indexes[c] = i
				if description != None:
					self.column_descriptions[c] = description
				i = i + 1
		elif tag == 'multival_columns':
			# the multival_columns specifies either
			# a "stop" column, usually the first one,
			# or a pair of column names separated by colon,
			# where the first on is column which should be
			# joined together and the second one is column
			# whose value should be used to distinguish if
			# we still have the same entity or not.
			for l in filter(lambda x: x != '', re.split('\n', value)):
				m = re.match('^\s*(\S+?)(\s*:\s*(\S*)\s*)?$', l)
				if m == None:
					continue
				( col, id_col ) = ( m.group(1), m.group(3) )
				if col != None:
					self.multival_column_names[col] = id_col
		elif tag == 'sql':
			self.sql = value
		elif tag == 'synopsis':
			self.synopsis = re.sub('^(\s*\n)+\s*|(\s*\n)+$', '', value)
		elif tag == 'description':
			self.description = re.sub('(?m)^\s*', '    ', re.sub('^(\s*\n)+\s*|(\s*\n)+$', '', value))
		else:
			raise spacewalk_report_unknown_tag_exception(tag)


class spacewalk_unknown_report(Exception):
	pass

class spacewalk_report_unknown_tag_exception(Exception):
	pass

class spacewalk_report_unknown_multival_column_exception(Exception):
	pass

