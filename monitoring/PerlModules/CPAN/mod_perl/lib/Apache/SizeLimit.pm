package Apache::SizeLimit;

=head1 NAME

Apache::SizeLimit - Because size does matter.

=head1 SYNOPSIS

This module allows you to kill off Apache httpd processes if they grow too
large.  You can choose to set up the process size limiter to check the
process size on every request:

    # in your startup.pl:
    use Apache::SizeLimit;
    $Apache::SizeLimit::MAX_PROCESS_SIZE = 10000; # in KB, so this is 10MB

    # in your httpd.conf:
    PerlFixupHandler Apache::SizeLimit
    # you can set this up as any Perl*Handler that handles part of the
    # request, even the LogHandler will do.

Or you can just check those requests that are likely to get big, such as
CGI requests.  This way of checking is also easier for those who are mostly
just running CGI.pm/Registry scripts:

    # in your CGI:
    use Apache::SizeLimit;
    &Apache::SizeLimit::setmax(10000);	# Max Process Size in KB

Since checking the process size can take a few system calls on some
platforms (e.g. linux), you may want to only check the process size every
N times.  To do so, put this in your startup.pl or CGI:

    $Apache::SizeLimit::CHECK_EVERY_N_REQUESTS = 2;

This will only check the process size every other time the process size
checker is called.

=head1 DESCRIPTION

This module is highly platform dependent, please read the CAVEATS section.

This module was written in response to questions on the mod_perl mailing
list on how to tell the httpd process to exit if it gets too big.

Actually there are two big reasons your httpd children will grow.  First,
it could have a bug that causes the process to increase in size
dramatically, until your system starts swapping.  Second, your process just
does stuff that requires a lot of memory, and the more different kinds of
requests your server handles, the larger the httpd processes grow over
time.

This module will not really help you with the first problem.  For that you
should probably look into Apache::Resource or some other means of setting a
limit on the data size of your program.  BSD-ish systems have setrlimit()
which will croak your memory gobbling processes.  However it is a little
violent, terminating your process in mid-request.

This module attempts to solve the second situation where your process
slowly grows over time.  The idea is to check the memory usage after every
request, and if it exceeds a threshold, exit gracefully.

By using this module, you should be able to discontinue using the Apache
configuration directive B<MaxRequestsPerChild>, although for some folks,
using both in combination does the job.  Personally, I just use the
technique shown in this module and set my MaxRequestsPerChild value to
6000.

=head1 CAVEATS

This module is platform dependent, since finding the size of a process
is pretty different from OS to OS, and some platforms may not be supported.

Currently supported OSes:

=over 4

=item linux

For linux we read the process size out of /proc/self/status.  This is
a little slow, but usually not too bad. If you are worried about
performance, try only setting up the the exit handler inside CGIs
(with the C<setmax> function), and see if the CHECK_EVERY_N_REQUESTS
option is of benefit.

=item solaris 2.6 and above

For solaris we simply retrieve the size of /proc/self/as, which
contains the address-space image of the process, and convert to KB.

NOTE: This is only known to work for solaris 2.6 and above. Evidently
the /proc filesystem has changed between 2.5.1 and 2.6. Can anyone
confirm or deny?

=item *bsd*

Uses BSD::Resource::getrusage() to determine process size.  This is pretty
efficient (a lot more efficient than reading it from the /proc fs anyway).

=item AIX?

Uses BSD::Resource::getrusage() to determine process size.

=back

If your platform is not supported, and if you can tell me how to check for
the size of a process under your OS (in KB), then I will add it to the list.
The more portable/efficient the solution, the better, of course.

=head1 TODO

Possibly provide a perl make/install so that the SizeLimit.pm is created at
build time with only the code you need on your platform.

If Apache was started in non-forking mode, should hitting the size limit
cause the process to exit?

=cut

use Apache::Constants qw(:common);
use Config;
use strict;
use vars qw($VERSION $HOW_BIG_IS_IT $MAX_PROCESS_SIZE
	    $REQUEST_COUNT $CHECK_EVERY_N_REQUESTS);

$VERSION = '0.03';
$CHECK_EVERY_N_REQUESTS = 1;
$REQUEST_COUNT = 1;

BEGIN {
    # decide at compile time how to check for a process' memory size.
    if (($Config{'osname'} eq 'solaris') &&
	 ($Config{'osvers'} >= 2.6)) {
	$HOW_BIG_IS_IT = \&solaris_2_6_size_check;
    } elsif ($Config{'osname'} eq 'linux') {
	$HOW_BIG_IS_IT = \&linux_size_check;
    } elsif ($Config{'osname'} =~ /(bsd|aix)/i) {
	# will getrusage work on all BSDs?  I should hope so.
	if (eval("require BSD::Resource;")) {
	    $HOW_BIG_IS_IT = \&bsd_size_check;
	} else {
	    die "you must install BSD::Resource for Apache::SizeLimit to work on your platform.";
	}
    } else {
	die "Apache::SizeLimit not implemented on your platform.";
    }
}

# return process size (in KB)
sub linux_size_check {
    my $size = 0;
    local(*FH);
    if (open(FH, "</proc/self/status")) {
	while (<FH>) { last if (($size) = (/^VmRSS:\s+(\d+)/)) }
	close(FH);
    } else {
	&error_log("Fatal Error: couldn't access /proc/self/status");
    }
    return($size);
}

sub solaris_2_6_size_check {
    my $size = -s "/proc/self/as" or
	&error_log("Fatal Error: /proc/self/as doesn't exist or is empty");
    $size = int($size/1024); # to get it into kb
    return($size);
}

sub bsd_size_check {
    return( (&BSD::Resource::getrusage())[2] );
}

sub exit_if_too_big {
    my $r = shift;
    return if ($REQUEST_COUNT++ < $CHECK_EVERY_N_REQUESTS);
    $REQUEST_COUNT = 1;
    if (defined($MAX_PROCESS_SIZE)) {
	my $size = &$HOW_BIG_IS_IT();
	if ($size > $MAX_PROCESS_SIZE) {
	    # I have no idea if this will work on anything but UNIX
	    if (getppid > 1) {	# this is a  child httpd
		&error_log("httpd process too big, exiting at SIZE=$size KB");
	        $r->child_terminate;
	    } else {		# this is the main httpd
		&error_log("main process too big, SIZE=$size KB");
	    }
	}
    } else {
	&error_log("you didn't set \$Apache::SizeLimit::MAX_PROCESS_SIZE");
    }
}

# setmax can be called from within a CGI/Registry script to tell the httpd
# to exit if the CGI causes the process to grow too big.
sub setmax {
    $MAX_PROCESS_SIZE = shift;
    Apache->request->post_connection(\&exit_if_too_big);
}

sub handler {
    my $r = shift || Apache->request;
    $r->post_connection(\&exit_if_too_big)
	if ($r->is_main);
    return(DECLINED);
}

sub error_log {
    print STDERR "[", scalar(localtime(time)), "] ($$) Apache::SizeLimit @_\n";
}

1;

=head1 AUTHOR

Doug Bagley <doug+modperl@bagley.org>, channeling Procrustes.

Brian Moseley <ix@maz.org>: Solaris 2.6 support

=cut
