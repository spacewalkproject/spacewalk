#!/usr/bin/perl
# perl makefile for the dobby module
#
# $Id$

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $file = qx|ls $ENV{'TOP'}/*.spec|;
chomp $file;
my $version = qx|grep '^Version: ' $file|;
chomp $version;
$version = (split /\s*:\s*/, $version)[-1];

die "No version or name from $file" unless $version;

WriteMakefile('NAME'	=> "Dobby",
	      'VERSION' => $version,
	      'LIBS'	=> [''], # e.g., '-lm'
	      'DEFINE'	=> '',	# e.g., '-DHAVE_SOMETHING'
	      'INC'	=> '',	# e.g., '-I/usr/include/other'
	      'MAKEFILE'  => "Makefile.perl", # the name of the output Makefile file
	      'EXE_FILES' => [ "scripts/db-control" ],
);

package MY;
sub tools_other {
	my $self = shift;
	my $ret = $self->SUPER::tools_other(@_);
	$ret =~ s/^(FIXIN\b.+)$/## $1\nFIXIN = \$(PERLRUN) -e 1/m;
	return $ret;
}
