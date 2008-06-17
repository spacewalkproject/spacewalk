#! /usr/local/bin/perl

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile being created.

require 5.004;

WriteMakefile(
	'NAME' => 'Crypt::DES',
	'DISTNAME' => 'Crypt-DES',
	'VERSION_FROM' => 'DES.pm',,
	'OBJECT' => 'DES.o _des.o',
	'dist'   => {COMPRESS=>'gzip', SUFFIX=>'gz'}
);

