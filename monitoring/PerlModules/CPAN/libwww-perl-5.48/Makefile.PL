# This -*- perl -*- script writes the Makefile for libwww-perl
# $Id: Makefile.PL,v 1.1 2000-10-14 00:56:56 dfaraldo Exp $

require 5.004;
use strict;

#--- Configuration section ---

my @programs_to_install = qw(lwp-request lwp-mirror lwp-rget lwp-download);
my @request_aliases     = qw(GET HEAD POST);

#--- End Configuration - You should not have to change anything below this line


# Allow us to suppress all program installation with the -n (library only)
# option.  This is for those that don't want to mess with the configuration
# section of this file.
use Getopt::Std;
use vars qw($opt_n);
unless (getopts("n")) {
    die "Usage: $0 [-n]\n";
}
@programs_to_install = () if $opt_n || grep /^LIB=/, @ARGV;


# Check for non-standard modules that are used by this library.
$| = 1;
my $missing_modules = 0;

print "Checking for URI...........";
eval {
    require URI;
    URI->VERSION(1.03);
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The URI module must be installed.  WWW without URIs would not
be that great :-)

EOT
    sleep(2);  # Don't hurry too much
} else {
    print " ok\n";
}
print "Checking for HTML::Parser..";
eval {
    require HTML::HeadParser;
    HTML::Parser->VERSION(2.20);
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The HTML::Parser is needed to extract correct <BASE> information from
HTML so that we can resolv relative links correctly.  The HTML::Form
module need HTML::TokeParser to work.

EOT
    sleep(2);  # Don't hurry too much
} else {
    print " ok\n";
}

print "Checking for MIME::Base64..";
eval {
    require MIME::Base64;
    #MIME::Base64->VERSION('2.00');
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The Base64 encoding is used in authentication headers in HTTP.

EOT
    sleep(2);  # Don't hurry too much
} else {
    print " ok\n";
}

print "Checking for Net::FTP......";
eval {
    require Net::FTP;
    Net::FTP->VERSION('2.00');
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The libwww-perl library normally use the Net::FTP module when
accessing ftp servers.  You would have to install this package or
configure your application to use a proxy server for making ftp
requests work.  Net::FTP is part of the 'libnet' distribution.

EOT
    sleep(2);  # Don't hurry too much
} else {
    print " ok\n";
}

print "Checking for Digest::MD5 ..";
eval {
    require Digest::MD5;
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The Digest::MD5 library is needed if you want to be able use the
experimental "Digest Access Authentication" scheme.  Since very few
servers implement this authentication scheme, you should normally not
worry too much about this.

EOT
} else {
    print " ok\n";
}

print <<EOT if $missing_modules;
The missing modules can be obtained from CPAN.  Visit
<URL:http://www.perl.com/CPAN/> to find a CPAN site near you.

EOT


# Ok, now it is time to really generate the Makefile
use ExtUtils::MakeMaker;

WriteMakefile(
   NAME          => 'libwww-perl',
   VERSION_FROM  => 'lib/LWP.pm',
   PL_FILES      => { map {("bin/$_.PL" => "bin/$_")} @programs_to_install },
   EXE_FILES     => [ map {"bin/$_"} @programs_to_install ],
   PREREQ_PM     => { 'URI'              => "1.03",
                      'MIME::Base64'     => "2.1",
                      'Net::FTP'         => "2.4",
                      'HTML::HeadParser' => 0,
                      'Digest::MD5'      => 0,
                     },
   'clean'       => { FILES => '$(EXE_FILES)' },
   'dist'        => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);



package MY;

sub postamble
{
    my @m;
    if (@request_aliases && grep($_ eq 'lwp-request', @programs_to_install)) {
	push @m, "all ::\n";
	if ($^O eq 'MSWin32') {
	    push @m, "\t\$(FULLPERL) -e \"use Config; chdir q[\$(INST_EXE)]; "
		    ."foreach (qw(@request_aliases)) { \" \\\n";
	    push @m, <<'EOT';
	-e "unlink \"$$_\"; " \
	-e "system(\"copy lwp-request $$_\") && die; }"
EOT
	} else {
	    push @m, "\t\$(FULLPERL) -e 'use Config; chdir q{\$(INST_EXE)}; "
		    ."foreach (qw(@request_aliases)) {' \\\n";
	    push @m, <<'EOT';
	-e 'unlink "$$_";' \
	-e 'system("$$Config{\"lns\"} lwp-request $$_") && die; }'
EOT
	}
    }
    join "", @m;
}

# What happens when we say 'make test'
sub test
{
    q(
TEST_VERBOSE=0

test: all
	$(FULLPERL) t/TEST $(TEST_VERBOSE)

);
}


# Determine things that should *not* be installed
sub libscan
{
    my($self, $path) = @_;
    return '' if $path =~ m/.(pl|dtd|sgml)$/;
    return '' if $path =~ m:\bCVS/:;
    return '' if $path =~ m/~$/;
    $path;
}

# Pass libwww-perl version number to pod2man
sub manifypods
{
    my $self = shift;
    my $ver = $self->{VERSION} || "";
    local($_) = $self->SUPER::manifypods(@_);
    s/pod2man\s*$/pod2man --release libwww-perl-$ver/m;
    $_;
}
