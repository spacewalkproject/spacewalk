use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Satcon',
    'VERSION_FROM'	=> 'lib/Satcon.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    'AUTHOR'            => 'Spacewalk <spacewalk-devel@redhat.com>',
    'EXE_FILES' => [ 'bin/satcon-build-dictionary.pl', 'bin/satcon-deploy-tree.pl', 'bin/satcon-make-rpm.pl'],
);
