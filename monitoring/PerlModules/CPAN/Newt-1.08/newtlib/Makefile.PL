use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Newt::newt',
    'SKIP'      => [qw(all static static_lib dynamic dynamic_lib test)],
    'INC'       => '-I/usr/include/slang',
    'clean'     => {'FILES' => 'libnewt$(LIB_EXT)'},
);

sub MY::top_targets {
'                       
all :: static

static ::       libnewt$(LIB_EXT)

libnewt$(LIB_EXT): $(O_FILES)
	$(AR) cr libnewt$(LIB_EXT) $(O_FILES)
	$(RANLIB) libnewt$(LIB_EXT)

';
}    
