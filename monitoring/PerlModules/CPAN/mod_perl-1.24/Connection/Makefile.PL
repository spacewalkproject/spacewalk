use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    'NAME'	=> 'Apache::Connection',
    'VERSION_FROM' => 'Connection.pm', # finds $VERSION
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);
