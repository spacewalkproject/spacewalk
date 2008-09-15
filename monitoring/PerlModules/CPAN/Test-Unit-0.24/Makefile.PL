use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

require 5.005;

WriteMakefile(
    'NAME'         => 'Test::Unit',
    'VERSION_FROM' => 'lib/Test/Unit.pm', # finds $VERSION
    'PREREQ_PM'    => {
                       Class::Inner   => 0,
                       Devel::Symdump => 0,
                       Error          => 0,
                       base           => 1,
                      },
);
