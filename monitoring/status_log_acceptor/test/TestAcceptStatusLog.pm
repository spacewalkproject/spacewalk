
package NOCpulse::AcceptStatusLog::test::TestAcceptStatusLog;

use strict;

use LWP::UserAgent;
use HTTP::Request;

use base qw(Test::Unit::TestCase);

sub test_error
{
    my $self = shift;

    my $request = HTTP::Request->new('POST', 'handler://NOCpulse::AcceptStatusLog');

    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);

    my $success = $response->is_success;
    my $status_line = $response->status_line();
    my $content = $response->content();

    $self->assert($status_line =~ /500/, "missing cluster id should cause error");

}

sub test_success
{
    my $self = shift;
    
    my $params = 'sat_cluster_id=34&avg_exec_time=3&avg_latency=3636&imminent_probes=1&last_check=1022803077&max_exec_time=180&max_latency=7448&min_exec_time=0&min_latency=0&pct_critical=9%2E33&pct_ok=46%2E83&pct_pending=0%2E00&pct_unknown=26%2E12&pct_warning=1%2E31&probe_count=536&recent_state_changes=&probe_state=18801%201022803285%20OK%20Updated%20status%20for%201%20check';

    my $request = HTTP::Request->new('POST', 'handler://NOCpulse::AcceptStatusLog');
    $request->content($params);
    
    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);
    
    my $success = $response->is_success;
    my $status_line = $response->status_line();
    my $content = $response->content();
    
    $self->assert($status_line =~ /200/, "valid request should be accepted");
    
}

1;

