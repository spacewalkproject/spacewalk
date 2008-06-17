package NetworkService::NNTP;

use strict;

use General::TCP;

sub run {
    my %args = @_;

    my $params = $args{params};

    $params->{service}    = 'NNTP';
    $params->{protocol}   = 'tcp';
    $params->{send}       = '';
    $params->{expect}     = '';
    $params->{read_bytes} = 256;
    $params->{quit}       = 'QUIT\n';

    General::TCP::run(%args);
}

1;
