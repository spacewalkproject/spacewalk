# Makefile.PL -- Makefile template for PodParser.
#
# This file is part of "PodParser". PodParser is free software;
# you can redistribute it and/or modify it under the same terms
# as Perl itself.

BEGIN {
    require 5.005;
    eval { require File::Spec };
    $@  and  die "You need to install the File::Spec module first!\n";
	if(($File::Spec::VERSION || 0) < 0.8) {
	  die "You need at least version 0.8 of the File::Spec module!\n";
	}
}

use ExtUtils::MakeMaker;

$DISTNAME  = "PodParser";    ## The "product" name for this distribution
$DISTMOD   = 'Pod::Parser';  ## The "title" module of this distribution
@MODULES   = ( $DISTMOD,     ## Other modules in this distribution
               qw( Pod::Checker
                   Pod::InputObjects
                   Pod::PlainText
                   Pod::Select
                   Pod::Usage
                 )
             );

## The executable scripts to be installed
@SCRIPTS   = qw( podchecker
                 podselect
                 pod2usage
               );
sub script($) { File::Spec->catfile ('scripts', @_) }
my @EXE_FILES = map { script $_ } @SCRIPTS;


## The test-script to execute regression tests (note that the
## 'xtra' directory might not exist for some installations)
@TESTPODS = ();
my $testdir  = File::Spec->catfile('t', 'pod');
my $test2dir = File::Spec->catfile($testdir, 'xtra');
my @testdirs = ($testdir);
push @testdirs, $test2dir if (-d $test2dir);
@TESTPODS = map { File::Spec->catfile($_, '*.t') } @testdirs;
@TESTPODS = map { glob } @TESTPODS if $^O eq 'MSWin32';

##-----------------------------------------------------------------------
## Instructions to write the Makefile (see Ext::MakeMaker)

WriteMakefile(
    NAME         => $DISTMOD,
    DISTNAME     => $DISTNAME,
    VERSION      => 1.18,
    PL_FILES     => { map { (script("$_.PL") => script($_)) } @SCRIPTS },
    EXE_FILES    => [ @EXE_FILES ],
    dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' },
    clean        => { FILES => "@EXE_FILES" },
    test         => { TESTS => "@TESTPODS" },
    ($] < 5.005 ?     ## Need File::Spec if this is 5.004 or earlier
       (PREREQ_PM  => {'File::Spec' => 0}) : ()),
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
       (ABSTRACT   => 'Modules for parsing/translating POD format documents',
        AUTHOR     => 'Brad Appleton <bradapp@enteract.com>') : ()),
);


