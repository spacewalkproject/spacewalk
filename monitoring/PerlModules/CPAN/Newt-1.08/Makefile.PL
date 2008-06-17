use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Newt',
    'LIBS'	=> ['-lslang '],   # e.g., '-lm' 
    'VERSION_FROM' => 'Newt.pm', # finds $VERSION
    'MYEXTLIB'  => 'newtlib/libnewt$(LIB_EXT)',
);

sub MY::postamble {
  '
$(MYEXTLIB): newtlib/Makefile
	cd newtlib && $(MAKE) $(PASTHRU)
';
}
