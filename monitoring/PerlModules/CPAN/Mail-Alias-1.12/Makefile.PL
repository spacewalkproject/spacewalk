# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use ExtUtils::MakeMaker;

BEGIN { require 5.001 }


#--- Write the Makefile

my @ppd;

if ($] >= 5.00503) {
  @ppd = (
    AUTHOR    => 'Tom Zeltwanger <perl@ename.com>',
    ABSTRACT  => 'Module for manipulating E_Mail Alias files'
  );
}

WriteMakefile(
	VERSION_FROM   => "Alias.pm",
	NAME      => "Mail::Alias",
	@ppd
);

