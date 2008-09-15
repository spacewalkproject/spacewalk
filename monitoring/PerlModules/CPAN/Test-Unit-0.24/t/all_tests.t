#!/usr/bin/perl -w

use strict;

use Test::Unit::Debug qw(debug_pkgs);
use Test::Unit::HarnessUnit;

#debug_pkgs(qw{Test::Unit::Result});

use lib 't/tlib', 'tlib';

my $testrunner = Test::Unit::HarnessUnit->new();
$testrunner->start("AllTests");
