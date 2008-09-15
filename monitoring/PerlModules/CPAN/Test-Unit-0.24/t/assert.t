#!/usr/bin/perl -w

use strict;

use Test::Unit::HarnessUnit;
use Test::Unit::Debug qw(debug_pkgs);

#debug_pkgs(qw/Test::Unit::Assert/);
#debug_pkgs(qw/Test::Unit::Assertion::CodeRef/);

use lib 't/tlib', 'tlib';

my $testrunner = Test::Unit::HarnessUnit->new();
$testrunner->start("AssertTest");
