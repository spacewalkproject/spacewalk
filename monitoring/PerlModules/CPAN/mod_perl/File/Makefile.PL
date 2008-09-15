use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    NAME        => "Apache::File",
    VERSION_FROM => "File.pm",
    'INC'       => $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);
