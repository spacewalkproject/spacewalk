package NetworkService::HTTP;

use strict;

use IO::Socket;
use Time::HiRes qw(gettimeofday tv_interval);
use LWP::UserAgent;
use HTTP::Cookies;
use URI::URL;

use NOCpulse::Log::Logger;
use ProbeMessageCatalog;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub run {
    my %args = @_;

    $ENV{'FTP_PASSIVE'} = 1;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $scheme = $params{scheme} || 'http';

    *LWP::UserAgent::get_basic_credentials = sub {
        my($me, $realm, $uri) = @_;
        my $netloc = $uri->host_port;
        my $user = $params{username};
        chomp($user);
        return (undef, undef) unless length $user;
        my $password = $params{password};
        chomp($password);
        return ($user, $password);
    };

    # Turn on debugging if requested
    eval "use LWP::Debug qw(+);" if ($Log->loggable(1));

    #BZ 165759: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my $host = $params{r_ip_0};
    my @octets = split(/\./, $host);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
	$octet = 0 unless $octet;
    }
    $host = join('.', @octets);

    # Construct the URL from command-line arguments
    my $uri = URI::URL->new($params{url});
    $uri->scheme($scheme);
    $uri->host($host);
    $uri->port($params{r_port_0});
    if ($params{r_svc_0} eq 'ftp') {
        $uri->user($params{username});
        $uri->password($params{password});
    }

    # Include support for cookies
    my $jar = HTTP::Cookies->new();
    my $ua  = LWP::UserAgent->new();
    $ua->agent($params{useragent});
    $ua->cookie_jar($jar);

    # NOTE:  HTTPS requests die on SIGPIPE when trying to contact a down
    #        server (with current libs, etc).  Need to ignore SIGPIPEs so 
    #        we can return a valid error status.
    $SIG{'PIPE'} = 'IGNORE';  

    my $timed_out = 0;
    local $SIG{'ALRM'} = sub { $timed_out = 1 };

    my $req = HTTP::Request->new(GET => $uri);
    if ($params{virtual_host}) {
        $req->header('Host' => $params{virtual_host});
    }

    my $start = [gettimeofday];

    alarm($params{timeout});
    my $res = $ua->request($req);
    alarm(0);

    if ($timed_out) {
        $result->item_critical(sprintf(ProbeMessageCatalog->instance->http('timed_out'),
				       $req->method, $req->uri, $params{timeout},
				       $res->status_line));
        return;
    }

    my $stop    = [gettimeofday];
    my $elapsed = tv_interval($start, $stop);

    $Log->log(2, "CODE:\n", $res->code, "\n");
    $Log->log(2, "RESULT:\n", $res->status_line, "\n");
    $Log->log(2, "HEADERS:\n", $res->headers_as_string, "\n");
    $Log->log(2, "CONTENT:\n", $res->content, "\n");

    unless ($res->is_success()) {
        $result->item_critical('HTTP request failed: ' . $res->status_line);

    } else {
        $result->context("URL \"$params{url}\"");

        # Check expected content and header strings.
        my $expect_header = $params{expect_header};
        if (defined($expect_header)) {
            my $headers = $res->headers_as_string;

            # Add response line to headers
            my $headers = join(' ', $res->protocol, $res->code, $res->message) .
              "\n$headers";

            if ($headers !~ /$expect_header/) {
                $result->item_critical("Headers do not include", "\"$expect_header\"");
            }
        }

        my $expect_content = $params{expect_content};
        if (defined($expect_content)) {
            my $content = $res->content;
            if ($content !~ /$expect_content/) {
                $result->item_critical("Content does not include", "\"$expect_content\"");
            }
        }

        $result->metric_value('latency', $elapsed, '%.3f');
        $result->item_value('Downloaded', length($res->content), '%d', units => 'bytes');
    }
}

1;
