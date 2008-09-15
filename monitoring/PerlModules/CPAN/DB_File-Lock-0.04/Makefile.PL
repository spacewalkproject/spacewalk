use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'DB_File::Lock',
    'VERSION_FROM' => 'Lock.pm', # finds $VERSION
);
