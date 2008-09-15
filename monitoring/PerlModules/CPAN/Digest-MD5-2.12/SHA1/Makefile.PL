require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'Digest::SHA1',
    'VERSION_FROM' => 'SHA1.pm',
    'dist'         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
