use ExtUtils::MakeMaker;

system('./Configure');

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'IPC::ShareLite',
    'VERSION_FROM' => 'ShareLite.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
    'OBJECT'    => 'sharelite.o ShareLite.o',
    'dist'      => {
        COMPRESS => 'gzip', SUFFIX => 'gz',
    },          
);
