use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Getresuid',
    'VERSION_FROM'	=> 'Getresuid.pm', # finds $VERSION
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Getresuid.pm', # retrieve abstract from module
       AUTHOR     => 'Dave Faraldo<lt>dfaraldo@redhat.com<gt>') : ()),
);
