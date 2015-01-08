#!/usr/bin/perl
# perl makefile for the pxt module
#

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $file = qx|ls $ENV{'TOP'}/*.spec|;
chomp $file;
my $version = qx|grep '^Version: ' $file|;
chomp $version;
$version = (split /\s*:\s*/, $version)[-1];

die "No version or name from $file" unless $version;

WriteMakefile('NAME'     => "PXT",
              'VERSION'  => $version,
              'LIBS'     => [''], # e.g., '-lm'
              'DEFINE'   => '', # e.g., '-DHAVE_SOMETHING'
              'INC'      => '', # e.g., '-I/usr/include/other'
              'MAKEFILE' => "Makefile.perl", #the name of the output Makefile file
);
