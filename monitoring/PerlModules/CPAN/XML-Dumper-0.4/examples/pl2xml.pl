#!/usr/bin/perl
#
# DESC: This script takes a Perl structure and dumps it to XML

# INCLUDES
use strict;
use XML::Dumper;

# MAIN
my $data = {
          'cat' => 'hat',
          'musak' => {
                       'movie' => {
                                    'Austin Powers' => 'Yeah Baby!'
                                  },
                       'primus' => 'sucks',
                       'jerry' => 'was a race car driver'
                     },
          'foo' => 'bar'
        };

# Dump Perl to XML
# create new instance of XML::Dumper
my $dump = new XML::Dumper;

# print the results
print $dump->pl2xml($data);


