#!/usr/bin/perl
use ExtUtils::MakeMaker;

#------------------------------------------------------------
# Makefile:
#------------------------------------------------------------

# Ensure the test output directory:
(-d "testout") or mkdir "testout", 0755 or die "please make dir ./testout\n";

# Write the Makefile:
WriteMakefile(
	      NAME         => "IO-stringy",
	      VERSION_FROM => "lib/IO/Stringy.pm",
	      DISTNAME     => "IO-stringy",
	      'dist'       => {
		  PREOP    => "cvu_perl_preop -m IO::Stringy -f",
		  COMPRESS => 'gzip',
		  SUFFIX   => 'gz',
	      }
	      );

