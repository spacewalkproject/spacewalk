use ExtUtils::MakeMaker;

use lib qw(../lib);
use Apache::src ();
my $src = Apache::src->new;

WriteMakefile(
    'NAME'	=> 'Apache::Table',
    'VERSION_FROM' => 'Table.pm', 
    'INC'	=> $src->inc,
    'TYPEMAPS'  => $src->typemaps,
);
