package NetworkService::HTTPS;

use strict;

use NetworkService::HTTP;

sub run {
    my %args = @_;
    $args{params}->{scheme} = 'https';
    NetworkService::HTTP::run(%args);
}

1;

