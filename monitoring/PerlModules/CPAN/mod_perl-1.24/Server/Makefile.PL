use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    'NAME'	=> 'Apache::Server',
    'VERSION_FROM' => 'Server.pm', 
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);
