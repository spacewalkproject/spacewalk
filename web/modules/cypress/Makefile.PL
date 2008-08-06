#!/usr/bin/perl
# perl makefile for the cypress module
#
# $Id$

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $file = qx|ls $TOP/*.spec|;
chomp $file;
my $version = qx|grep '^Version: ' $file|;
chomp $version;
$version = (split /\s*:\s*/, $version)[-1];

die "No version or name from $file spec" unless $version;

WriteMakefile('NAME'	=> "Cypress",
	      'VERSION' => $version,
	      'LIBS'	=> [''], # e.g., '-lm'
	      'DEFINE'	=> '',	# e.g., '-DHAVE_SOMETHING'
	      'INC'	=> '',	# e.g., '-I/usr/include/other'
	      'MAKEFILE' => "Makefile.perl", # the name of the output Makefile file
);
