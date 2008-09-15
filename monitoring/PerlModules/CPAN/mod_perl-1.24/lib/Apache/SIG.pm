package Apache::SIG;

use strict;
$Apache::SIG::VERSION = '1.91';

$Apache::SIG::PipeKey ||= 'SIGPIPE';

sub set {
    $SIG{PIPE} = \&PIPE;
}

sub handler {
    my $r = shift;
    if ($r->is_main) {
        $r->request($r);
        $SIG{PIPE} = \&PIPE;
    }
}

sub PIPE {
    my $ppid = getppid;
    my $s = ($ppid > 1) ? -2 : 0;

    if (my $r = Apache->request) {
        $r->subprocess_env($Apache::SIG::PipeKey => '1');
    } else {
        warn "[modperl] caught SIGPIPE in process $$\n";
        warn "\thint: may be a client (browser) hit STOP?\n";
        warn "[modperl] process $$ going to Apache::exit with status=$s\n";
    }
    Apache::exit($s);
}

1;

__END__

=head1 NAME

Apache::SIG - Override apache signal handlers with Perl's

=head1 SYNOPSIS

 PerlFixupHandler Apache::SIG

=head1 DESCRIPTION

When a client drops a connection and apache is in the middle of a
write, a timeout will occur and httpd sends a B<SIGPIPE>.  When
apache's SIGPIPE handler is used, Perl may be left in the middle of
it's eval context, causing bizarre errors during subsequent requests
are handled by that child.  When Apache::SIG is used, it installs a
different SIGPIPE handler which rewinds the context to make sure Perl
is back to normal state, preventing these bizarre errors.

If you would like to log when a request was cancelled by a SIGPIPE in your
Apache access_log, you can declare Apache::SIG as a handler (any
Perl*Handler will do, as long as it is run before PerlHandler,
e.g. PerlFixupHandler), and you must also define a custom LogFormat in your
httpd.conf, like so:

PerlFixupHandler Apache::SIG
LogFormat "%h %l %u %t \"%r\" %s %b %{SIGPIPE}e"

If the server has noticed that the request was cancelled via a SIGPIPE,
then the log line will end with C<1>, otherwise it will just be a dash.

=head1 CAVEATS

The signal handler in this package uses the subprocess_env table of the
main request object to supply the 'SIGPIPE' "environment variable" to
the log handler. If you already use the key 'SIGPIPE' in your
subprocess_env table, then you can redefine the key like this:

$Apache::SIG::PipeKey = 'my_SIGPIPE';

and log it like this:

LogFormat "%h %l %u %t \"%r\" %s %b %{my_SIGPIPE}e"

=head1 AUTHORS

Doug MacEachern and Doug Bagley

=head1 SEE ALSO

perlvar(1)

=cut
