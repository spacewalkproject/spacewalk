require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'Digest::MD2',
    'VERSION_FROM' => 'MD2.pm',
    'dist'         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
