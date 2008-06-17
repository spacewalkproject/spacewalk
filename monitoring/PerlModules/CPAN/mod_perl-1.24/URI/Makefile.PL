use ExtUtils::MakeMaker;
use Config;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    NAME	=> "Apache::URI",
    VERSION_FROM => "URI.pm",
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);

