use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    NAME	=> "Apache::ModuleConfig",
    VERSION_FROM => "ModuleConfig.pm",
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);

