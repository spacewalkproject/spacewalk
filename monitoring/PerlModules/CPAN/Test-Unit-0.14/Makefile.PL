use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	   => 'Test::Unit',
    'VERSION_FROM' => 'lib/Test/Unit.pm', # finds $VERSION
);
