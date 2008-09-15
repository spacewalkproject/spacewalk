use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    'NAME'	=> 'Apache::Util',
    'VERSION_FROM' => 'Util.pm', # finds $VERSION
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);
