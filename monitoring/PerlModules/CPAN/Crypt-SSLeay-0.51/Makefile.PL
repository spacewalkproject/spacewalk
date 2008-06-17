#!/usr/local/bin/perl

use strict;
use ExtUtils::MakeMaker;
use File::Basename qw(dirname basename);
use Getopt::Long;
use vars qw($opt_default);

&GetOptions("default", \$opt_default);

$opt_default ||= $ENV{CRYPT_SSLEAY_DEFAULT};
my $currdir = dirname($0) || '.';
chdir($currdir) || die("can't change to $currdir: $!");

# FIND POSSIBLE SSL INSTALLATIONS
my @POSSIBLE_SSL_DIRS = qw(/usr/local/openssl /usr/local/ssl /local/ssl /opt/ssl /usr/local /local /usr);
if($^O eq 'MSWin32') {
    unshift(@POSSIBLE_SSL_DIRS, 'c:/openssl');
}

my @CANDIDATE;
my $open_ssl = 0;
my $dir;
for $dir (@POSSIBLE_SSL_DIRS) {
    next unless -d $dir;
    my $candidate = Candidate($dir);
    next unless $candidate;

    push(@CANDIDATE, $candidate);
}

if (@CANDIDATE == 1) {
    my($dir, $inc_dir, $ver) = @{$CANDIDATE[0]};
    print "Found OpenSSL (version $ver) installed at $dir\n";
} elsif (@CANDIDATE > 1) {
    print "Found the following OpenSSL installations:\n";
    for (@CANDIDATE) {
	my($dir, $inc_dir, $ver) = @$_;
	print "\t$ver\t$dir\n";
    }
}

my $SSL_DIR;
if($opt_default && (@CANDIDATE == 1) && $CANDIDATE[0][0]) {
    $SSL_DIR = $CANDIDATE[0][0];
    print "Using --default OpenSSL candidate found at $SSL_DIR\n";
} else {
    if($ARGV[0] =~ /^[a-z]\:|^\//i) {
	$SSL_DIR = shift;
    } else {
	unless($CANDIDATE[0][0]) {
	    print "No OpenSSL installation found, usually in $POSSIBLE_SSL_DIRS[0]\n";
	}
	$SSL_DIR = prompt "Which OpenSSL build path do you want to link against?", $CANDIDATE[0][0];
    }
}

my $candidate = &Candidate($SSL_DIR);
unless($candidate) {
    warn "Apparently no SSLeay installation at '$SSL_DIR'\nAre you sure you got it correct????\n"
      unless -f "$SSL_DIR/include/ssl.h";
}
$candidate ||= ["$SSL_DIR", "$SSL_DIR/include"];

my($SEP, $SSL_LIB, $SSL_INC, $LIBS);
$SSL_INC = "$SSL_DIR/include";

if($^O =~ /Win32/) {
    unless($SSL_DIR =~ /^[a-zA-Z]\:/) {
	# default drive c
	$SSL_DIR = "c:".$SSL_DIR;
    }
    unless($SSL_INC =~ /^[a-zA-Z]\:/) {
	# default drive c
	$SSL_INC = "c:".$SSL_INC;
    }
    $SSL_INC .= " -I".$SSL_DIR."/inc32";
    $SSL_DIR =~ s|/|\\|g;
    $SSL_INC =~ s|/|\\|g;

    # patch from Ben Laurie
    if(-d "$SSL_DIR/lib") {
	$SSL_LIB = "-L$SSL_DIR/lib";
    } elsif(-d "$SSL_DIR/out32dll") {
	$SSL_LIB = "-L$SSL_DIR\\out32dll";	
    }else {
	# Allow developers to point at OpenSSL source...
	$SSL_LIB = "-L$SSL_DIR";
    }

    $SEP = "\\";
    $LIBS = "-lssleay32 -llibeay32 -lRSAglue -lrsaref";
} else {
    $SSL_LIB = "-L".$SSL_DIR."/lib";
    $SEP = "/";
    $LIBS = "-lssl -lcrypto -lgcc -lRSAglue -lrsaref";

    # ccc on alpha support
    if ($^O eq 'linux' && `uname -m` =~ /alpha/ &&
	!(system("nm $SSL_DIR/lib/libssl.a|grep -q 'U _Ots'")>>8)) {
	$LIBS .= ' -lots'; 
    }

    # this fix was suggested for building on RedHat 9
    if(-d '/usr/kerberos/include') {
	$SSL_INC .= " -I/usr/kerberos/include";
    }
}

# write include file that determing ssl support
my $ssl_header_prefix = '';
my $candidate_info = join('; ', @$candidate);
if($candidate->[1] =~ /openssl/i) {
    $ssl_header_prefix = "openssl/";
}

## we need to include crypto.h for SSLeay so the version gets
## picked up in SSLeay.xs
open(INCLUDE, ">crypt_ssleay_version.h") || die("can't open crypt_ssleay_version.h for writing: $!");
print INCLUDE "#include \"".$ssl_header_prefix."ssl.h\"\n";
print INCLUDE "#include \"".$ssl_header_prefix."crypto.h\"\n";
print INCLUDE "#include \"".$ssl_header_prefix."err.h\"\n";
print INCLUDE "#include \"".$ssl_header_prefix."rand.h\"\n";
print INCLUDE "#include \"".$ssl_header_prefix."pkcs12.h\"\n";
if($] < 5.005) {
    warn "writing PL_sv_undef symbol";
    print INCLUDE "#ifndef PL_sv_undef\n";
    print INCLUDE "#define PL_sv_undef sv_undef\n";
    print INCLUDE "#endif\n";
}

# OPENSSL_free defined in OpenSSL 0.9.6 and higher
my $openssl_version = $candidate->[2];
if(($openssl_version =~ /^OpenSSL/) and ($openssl_version !~ /0\.9\.[2-5]/)) {
    print INCLUDE "#define CRYPT_SSLEAY_free OPENSSL_free\n";
} else {
    print INCLUDE "#define CRYPT_SSLEAY_free free\n";
}

close INCLUDE;

print <<INFO;

================================================
BUILD INFORMATION
================================================

ssl dir:	$SSL_DIR
libraries:      $LIBS
include dir:	$SSL_INC
ssl header:     @{[$ssl_header_prefix]}ssl.h
ssl candidate:  $candidate_info

================================================

INFO
  ;

# set the path for testing
$ENV{PATH} = "$SSL_LIB:$ENV{PATH}";

WriteMakefile(
    NAME    => 'Crypt::SSLeay',
    VERSION_FROM => 'SSLeay.pm',
    LIBS    => ["$SSL_LIB $LIBS"],
    INC     => "-I".$SSL_INC,
    dist    => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);

## HELPERS

sub Candidate {
    my $dir = shift;
    my $version_file;
    my $inc_dir;

    for (
	 "$dir/crypto/opensslv.h", # cygwin32 builds
	 "$dir/inc32/openssl/opensslv.h", # win32 builds
	 "$dir/include/openssl/opensslv.h", 
	 "$dir/include/opensslv.h", 
	 "$dir/include/crypto.h"
	) 
      {
	  if(-e $_) {
	      $version_file = $_;
	  } 
      }
    return unless defined $version_file;

    $open_ssl = ($version_file =~ /openssl/) ? 1 : 0;
    my $dirname = $inc_dir = dirname($version_file);
    return unless (-e "$dirname/ssl.h");

    open(VERSION_FILE, $version_file) or return;
    my $version_match = $open_ssl ? "OPENSSL_VERSION_NUMBER" : "SSLEAY_VERSION_NUMBER";
    my $version;
    while (<VERSION_FILE>) {
	if (/^\#define\s+$version_match\s+0x0+(\d\d\d)/) {
	    $version = $1;
	    $version =~ s/(\d)0(\d)/$1$2/;	    
	    my $type = ($version > 92) ? "OpenSSL" : "SSLeay";
	    $version = "$type ".join('.', split(//, "0$version"));
	    last;
	}
    }
    close(VERSION_FILE);

    # Silly test to look for the library files
    my $foundlib = 0;
    my $libd = (-d "$dir/out32dll") ? 'out32dll' : 'lib';
    if (opendir(LIBDIR, "$dir/$libd")) {
	while (defined($_ = readdir(LIBDIR))) {
	    $foundlib++ if /^libssl/;
	    $foundlib++ if /^libcrypto/;
	    $foundlib++ if /^ssleay32/;
	    $foundlib++ if /^libeay32/;
	}
	closedir(LIBDIR);
    }
    warn "$dir/lib does not seem to contain the SSLeay library files\n"
	unless $foundlib;

    [$dir, $inc_dir, $version];
}


