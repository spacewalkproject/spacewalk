#!/usr/bin/perl
# perl makefile for the pxt module
#
# $Id$

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my ($version, $release) = split /\s+/, `cat \${TOP}/version`;

die "No version or name from $module.spec" unless $version;

WriteMakefile('NAME'	 => "PXT",
	      'VERSION'  => $version,
	      'LIBS'	 => [''], # e.g., '-lm'
	      'DEFINE'	 => '',	# e.g., '-DHAVE_SOMETHING'
	      'INC'	 => '',	# e.g., '-I/usr/include/other'
	      'MAKEFILE' => "Makefile.perl", #the name of the output Makefile file
);
