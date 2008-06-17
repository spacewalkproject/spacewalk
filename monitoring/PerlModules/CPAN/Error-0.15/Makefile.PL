use ExtUtils::MakeMaker;
use 5.004;

my @ppd;

if ($] >= 5.00503) {
  @ppd = (
    AUTHOR    => 'Graham Barr <gbarr@pobox.com>',
    ABSTRACT  => 'Error/exception handling in an OO-ish way'
  );
}

WriteMakefile(
	NAME	     => 'Error',
	VERSION_FROM => 'Error.pm',
	@ppd
);

sub MY::postamble {

  return '' unless $] >= 5.00503;

<<'ESQ';

dist : ppd

ESQ
}

