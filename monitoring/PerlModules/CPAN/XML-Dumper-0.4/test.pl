#!/usr/bin/perl -w

use strict;
use XML::Dumper;

my $dump = new XML::Dumper;
$dump->TestRoundTrip;
