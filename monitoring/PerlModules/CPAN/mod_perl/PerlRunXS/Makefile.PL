use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    'NAME'	=> 'Apache::PerlRunXS',
    'VERSION_FROM' => 'PerlRunXS.pm',
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);
