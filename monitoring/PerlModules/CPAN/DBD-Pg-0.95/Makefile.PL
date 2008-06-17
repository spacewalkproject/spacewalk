
# $Id: Makefile.PL,v 1.1.1.1 2001-01-12 20:41:07 dparker Exp $

use ExtUtils::MakeMaker;
use Config;
use strict;
use DBI 1.00;
use DBI::DBD;

print "Configuring Pg\n";
print "Remember to actually read the README file !\n";

my $POSTGRES_INCLUDE;
my $POSTGRES_LIB;

if ((!$ENV{POSTGRES_INCLUDE} or !$ENV{POSTGRES_LIB}) and !$ENV{POSTGRES_HOME}) {
    die "please set environment variables POSTGRES_INCLUDE and POSTGRES_LIB !\n";
} elsif ((!$ENV{POSTGRES_INCLUDE} or !$ENV{POSTGRES_LIB}) and $ENV{POSTGRES_HOME}) {
    $POSTGRES_INCLUDE = "$ENV{POSTGRES_HOME}/include";
    $POSTGRES_LIB     = "$ENV{POSTGRES_HOME}/lib";
} else {
    $POSTGRES_INCLUDE = "$ENV{POSTGRES_INCLUDE}";
    $POSTGRES_LIB     = "$ENV{POSTGRES_LIB}";
}

my $os = $^O;
print "OS: $os\n";

my $dbi_arch_dir;
if ($os eq 'MSWin32') {
    $dbi_arch_dir = "\$(INSTALLSITEARCH)/auto/DBI";
} else {
    $dbi_arch_dir = dbd_dbi_arch_dir();
}

my %opts = (
    NAME         => 'DBD::Pg',
    VERSION_FROM => 'Pg.pm',
    INC          => "-I$POSTGRES_INCLUDE -I$dbi_arch_dir",
    OBJECT       => "Pg\$(OBJ_EXT) dbdimp\$(OBJ_EXT)",
    LIBS         => ["-L$POSTGRES_LIB -lpq"],
    AUTHOR       => 'Edmund Mergl (E.Mergl@bawue.de)',
    ABSTRACT     => 'PostgreSQL database driver for the DBI module',
);

if ($os eq 'hpux') {
    my $osvers = $Config{osvers};
    if ($osvers < 10) {
        print "Warning: Forced to build static not dynamic on $os $osvers.\a\n";
        $opts{LINKTYPE} = 'static';
    }
}

if ($Config{dlsrc} =~ /dl_none/) {
    $opts{LINKTYPE} = 'static';
}


WriteMakefile(%opts);

exit(0);

# end of Makefile.PL
