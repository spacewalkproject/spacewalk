package NOCpulse::SatConfig::test::TestGenerateConfig;

use strict;

use LWP::UserAgent;
use HTTP::Request;

use base qw(Test::Unit::TestCase);

sub test_generate_config {
    my $self = shift;

    my $request = HTTP::Request->new('POST', 'handler://NOCpulse::SatConfig::GenerateConfig');
    $request->content('satcluster=35');

    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);

    my $success = $response->is_success;
    my $status_line = $response->status_line();

    $self->assert( $status_line =~ /200/,
                   "Generate with satcluster=35 has wrong status: $status_line");

    my $content = $response->content();
    $self->assert( $content =~ /perldata/,
                   "Config generation with satcluster=35 does not include perldata");
}

1;




