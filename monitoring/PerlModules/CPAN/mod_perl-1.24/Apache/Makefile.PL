use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    NAME	=> "Apache",
    VERSION_FROM => "Apache.pm",
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);

