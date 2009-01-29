use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'		=> 'NOCpulse::Debug',
    'VERSION_FROM'	=> 'Debug.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    'PM'                => {
                            'Debug.pm'      => '$(INST_LIBDIR)/Debug.pm',
                            'Debuggable.pm' => '$(INST_LIBDIR)/Debuggable.pm',
                            'DependencyGraph.pm' => '$(INST_LIBDIR)/DependencyGraph.pm',
                            'Log/Logger.pm'     => '$(INST_LIBDIR)/Log/Logger.pm',
                            'Log/LogManager.pm' => '$(INST_LIBDIR)/Log/LogManager.pm',
                            'Log/test/TestLogger.pm' => '$(INST_LIBDIR)/Log/test/TestLogger.pm',
                           },    
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Debug.pm', # retrieve abstract from module
       AUTHOR     => 'Frank Paturzo, Dave Faraldo <dfaraldo@redhat.com>') : ()),
);

