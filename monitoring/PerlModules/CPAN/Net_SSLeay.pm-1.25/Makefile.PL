#!/usr/bin/perl
# 23.6.1998, Sampo Kellomaki <sampo@iki.fi>
# 30.7.1999, upgraded for OpenSSL-0.9.3a --Sampo
# 7.4.2001,  upgraded to OpenSSL-0.9.6a --Sampo
# 15.4.2001, fixed little bug in ssl directory detection --Sampo
# 18.7.2001, fixed numerous issues reported by Eric A Selber
#	     <eselber@briefcase.com> that made Windows builds painful --Sampo
# 20.8.2001, tweaked path editing, thanks to Gordon Lack
#            <gml4410@@ggr.co.uk> --Sampo
# 19.4.2003, applied some RH9 fixes from priit.randla@eyp._ee --Sampo
# $Id: Makefile.PL,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
#
# Configuration script for Net::SSLeay.pm

$usage = <<USAGE
Usage: ./Makefile.PL [-windows] [-rsaref] [-m|-t|-d] [-g] [OpenSSL install path] [-- args]
           -m and -t  will automatically build and test, respectively
           -d         builds and tests verbosely
           -g         Compile for debugging (see README)
           -rsaref    provides support for linking against rsaref
           -windows   sets library paths for windows build
           --         Introduces arguments for Make::Maker. Typically used
                      to pass PREFIX=/path/to/your/perl/libs
E.g:   ./Makefile.PL -d
       ./Makefile.PL -t /apps/openssl/std -- PREFIX=/home/koerkki/perllib

Note: For Windows builds openssl installation path must always be given.
USAGE
    ;
die $usage if grep /^--?[hv?]/i, @ARGV;

use ExtUtils::MakeMaker;
use Config;

$windows = shift if $ARGV[0] eq '-windows';
$rsaref  = shift if $ARGV[0] eq '-rsaref';
$make_it = shift if $ARGV[0] eq '-m';
$test_it = shift if $ARGV[0] eq '-t';
$debug = $test_it = shift if $ARGV[0] eq '-d';
$optimize = '-O';
$optimize = shift if $ARGV[0] eq '-g';

# It seems at least Redhat installs OpenSSL in /usr ...
$openssl_path = '/usr' if -x '/usr/bin/openssl' || -x '/usr/sbin/openssl';
$openssl_path = '/opt/ssl' if -x '/opt/ssl/bin/openssl'
    || -x '/opt/ssl/sbin/openssl';
$openssl_path = '/usr/local/ssl' if -x '/usr/local/ssl/bin/openssl';
$openssl_path = '/apps/openssl/std' if -x '/apps/openssl/std/bin/openssl';
$openssl_path = shift if @ARGV && $ARGV[0] ne '--';

shift if $ARGV[0] eq '--';   # Rest of args are for MakeMaker

$openssl_vers = '0.9.6j';
$openssl_vers2 = '0.9.7b';

print "Checking for OpenSSL-$openssl_vers or $openssl_vers2 or newer...\n";

while (1) {
    $exe_path = "$openssl_path/bin/openssl";
    last if -x $exe_path;
    $exe_path = "$openssl_path/bin/openssl.exe";
    last if -x $exe_path;
    $exe_path = "$openssl_path/sbin/openssl";
    last if -x $exe_path;
    $exe_path = "$openssl_path/out32dll/openssl.exe";
    last if -x $exe_path;

    print "I could not find your OpenSSL in `$openssl_path'\n";
    print "Please provide OpenSSL-$openssl_vers or\n"
	. "OpenSSL-$openssl_vers2 installation directory (get from\n"
	." http://www.openssl.org/ if you don't have it; please note that\n"
	    ." SSLeay is no longer supported, see README) (C-c to abort):\n";
    $openssl_path = <STDIN>;
    chomp $openssl_path;
}

$vers = `$exe_path version`
    or die "Couldn't run `$exe_path' ($?)\n";

unless (($lib_name, $maj, $min, $letter) = $vers =~
	/^(OpenSSL)\s+(\d+\.\d+)\.(\d+)([a-z]*)/) {
    die "OpenSSL version test failed (`$vers' was returned, but\n"
    . "couldn't be parsed). Either you have bogus OpenSSL or a new version\n"
    . "has changed the version number format.\n";
}

print "You have $lib_name-$maj.$min$letter installed in $openssl_path\n";

die "That's too old. Please upgrade to OpenSSL-$openssl_vers or\n"
    . "OpenSSL-$openssl_vers2\n"
    . "before trying to install this module. If you can't upgrade,\n"
    . "see README for other options (like older versions of this module).\n"
    if $maj eq '0.9' && $min < 3;

warn "That's is newer than what this module was tested with ($openssl_vers\n"
    . "or $openssl_vers2). You should\n"
    . "consider checking if there is a newer release of this module\n"
    . "available. Everything will probably work OK, though.\n"
    if $maj > 0.9 || $min > 7;

warn "openssl-0.9.6i/0.9.7a and earlier versions have security flaws or bugs,\n"
    . "see advisories at www.openssl.org, upgrading to openssl-$openssl_vers\n"
    . "or openssl-$openssl_vers2 is recommended.\n"
    if $maj eq '0.9' && (($min == 6 && $letter lt 'j') || ($min == 7 && $letter lt 'b'));

open F, ">openssl_path" or die "Can't write ./openssl_path: $!";
print F $exe_path;  # used by test.pl and examples/makecert.pl
close F;

### The windows option tweaking details supplied by
### Eric A Selber <eselber@@briefcase_.com>. This is
### still experimental until I get success reports.

if ($windows) {
    warn "RSAREF build on Windows not supported out of box" if $rsaref;
    $libs = "-llibeay32 -lssleay32";

    warn "Be sure to use the same compiler and options to compile your OpenSSL, perl, and Net::SSLeay. Mixing and matching compilers is not supported. (Currently I do not have a way to check this on Windows platform.)\n";
} else {
    ### There is some confusion over the correct ordering
    ### of these libraries. Tarang Kumar Patel <mombasa@ptolemy.arc.nasa.gov>
    ### reports this order to work on Solaris 7 and openssl-0.9.6b
    $libs = $rsaref ? "-lssl -lcrypto -lRSAglue -lrsaref" : "-lssl -lcrypto";
    
    ### old order which might work on some platforms
    #$libs = $rsaref ? "-lssl -lRSAglue -lcrypto -lrsaref" : "-lssl -lcrypto";

    ### Check that perl and openssl were compiled using the same compiler
    ### and options.

    ($cc_et_alia) = grep /cc\s+-/i, `strings $exe_path`;
    if ($cc_et_alia) {
	($cc, %flags) = split /\s+/, $cc_et_alia;
	if ($cc eq $Config{cc}) {
	    warn "Good. Both OpenSSL and perl seem to have been compiled with the same compiler.\n";
	} else {
	    warn "*** $exe_path appears to be compiled with $cc ($cc_et_alia) while perl is compiled with $Config{cc}. Both must be compiled with the same compiler and flags. Mixing and matching compilers is not supported.";
	}
    } else {
	warn "*** Could not figure out which C compiler was used to compile $exe_path. It is essentiall that OpenSSL, perl, and Net::SSLeay are compiled with the same compiler and flags. Mixing and matching compilers is not supported.";
    }

    ### When using aCC under HP-UX additional `+e' flag must be passed.
    ### As the CCFLAGS is almost correct I abuse the OPTIMIZE to pass
    ### this additional flag. Thanks to Marko Asplund (aspa@@kronodoc._fi)
    ### for doing this bit of detective work.
    
    if (($cc =~ /aCC/i) && ($cc_et_alia =~ /hpux/i)) {
	warn "Enabling HPUX aCC options (+e)\n";
	$optimize = '+e ' . $optimize;
    }

    ### An unknown contributor (sorry about loosing your name) hinted
    ### that under gcc -fPIC will run faster than -fpic and still
    ### be binary compatible.

    if( ($Config{cc} eq 'gcc') && ($Config{'cccdlflags'} =~ /-fpic/) ) {
	warn "Enabling gcc -fPIC optimization\n";
	($more_params{CCCDLFLAGS} = $Config{'cccdlflags'}) =~ s/-fpic/-fPIC/;
    }
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my %configParams = (
    NAME	=> 'Net::SSLeay',
    VERSION_FROM => 'SSLeay.pm', # finds $VERSION
    DIR         => [ 'Net-SSLeay-Handle-0.50' ],
    DEFINE      => '-DPERL5 -DOPENSSL_NO_KRB5',   # perl-5.8/gcc-3.2 needs first, RH9 latter
    DISTNAME    => 'Net_SSLeay.pm',
    dist        => { COMPRESS => 'gzip', SUFFIX => 'gz', },
    LIBS	=> ["-L$openssl_path -L$openssl_path/lib -L$openssl_path/out32dll $libs"],
    INC 	=> "-I$openssl_path/include -I$openssl_path/inc32 -I/usr/kerberos/include",
    OPTIMIZE    => $optimize,
# Uncomment (and edit) following for debugging with gdb
#    LIBS	=> ['-L/usr/src/openssl-0.9.3a -lssl -lcrypto'],
#    INC	=> '-I/usr/src/openssl-0.9.3a/include',
#    OPTIMIZE   => '-g',
	      %more_params,
);

WriteMakefile(%configParams);

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
#WriteMakefile(
#    'NAME'	   => 'Net::SSLeay::Handle',
#    'VERSION_FROM' => 'Handle.pm', # finds $VERSION
#);

$ENV{TEST_TRACE} = 2 if $debug;
exec "make" if $make_it;
exec "make test" if $test_it;

__END__
