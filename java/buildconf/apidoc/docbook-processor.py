# ==================================================
# API Documentation Section Processor
# V1.0
# 
# This script is a post-processor for apidoc-docbook
# output that adds a 'Name' attribute to each item,
# and adds bolding to variable names marked up with
# quotation marks.
# ==================================================

import os
import re
import sys


def print_header():

    print '=================================================='
    print 'API Documentation Section Processor               '
    print '=================================================='
    print ''


# Start of main routine
__correction_count__ = 0

print_header()

# Walk the directory tree and check all XML files
for dir_name, sub_dir_list, file_list in os.walk('.'):

    # Skip private directories
    if dir_name.startswith('./.'):

        continue

    # Print processing message
    print('Processing %s...\n' % dir_name)

    # Process all AsciiDoc files
    for file_name in file_list:

        if file_name.endswith('xml'):

            print file_name

            lines = open(os.path.abspath(dir_name) + "/" + file_name,'r').read()

            __correction_count__ += 1

            with open(os.path.abspath(dir_name) + "/" + file_name,'w') as file:

                # Section headers
                regex_sec1 = '<sect1>(.*?)<title>(.*?)<function>(.*?)</function>(.*?)</title>'
                regex_sec2 = '<title><function>(.*?)</function></title>(.*?)<variablelist>'

                lines = re.sub(regex_sec1, r'<sect1>\n  <title><function>\3</function></title>', lines, flags=re.S)
                lines = re.sub(regex_sec2, r'<title><function>\1</function></title>\n  <variablelist>\n    <varlistentry>\n      <term>Name</term>\n      <listitem><para>\1</para></listitem>\n    </varlistentry>\n', lines, flags=re.S)

                # Variables
                regex_int = 'int "(.*?)"'
                regex_str1 = 'string "(.*?)"'
                regex_str2 = 'String "(.*?)"'
                regex_bol1 = 'boolean "(.*?)"'
                regex_bol2 = 'Boolean "(.*?)"'
                regex_bol3 = 'bool "(.*?)"'
                regex_array = 'array "(.*?)"'
                regex_struct = 'struct "(.*?)"'
                regex_dat1 = 'date "(.*?)"'
                regex_dat2 = 'dateTime.iso8601 "(.*?)"'

                lines = re.sub(regex_int, r'int <literal>\1</literal>', lines)
                lines = re.sub(regex_str1, r'string <literal>\1</literal>', lines)
                lines = re.sub(regex_str2, r'String <literal>\1</literal>', lines)
                lines = re.sub(regex_bol1, r'boolean <literal>\1</literal>', lines)
                lines = re.sub(regex_bol2, r'Boolean <literal>\1</literal>', lines)
                lines = re.sub(regex_bol3, r'bool <literal>\1</literal>', lines)
                lines = re.sub(regex_array, r'array <literal>\1</literal>', lines)
                lines = re.sub(regex_struct, r'struct <literal>\1</literal>', lines)
                lines = re.sub(regex_dat1, r'date <literal>\1</literal>', lines)
                lines = re.sub(regex_dat2, r'dateTime.iso8601 <literal>\1</literal>', lines)

                # Empty para blocks
                regex_par = '  <para/>'

                lines = re.sub(regex_par, '', lines)

                # Write parsed lines
                file.write(lines)

print('\nChecked %s sections.\n' % __correction_count__)

