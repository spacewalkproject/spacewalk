package NetworkService::IMAP;

use strict;

use General::TCP;

sub run {
    my %args = @_;

    my $params = $args{params};

    $params->{service}    = 'IMAP';
    $params->{protocol}   = 'tcp';
    $params->{send}       = '';
    $params->{expect}     = '';
    $params->{read_bytes} = 256;
    $params->{quit}       = 'a1 LOGOUT\n';

    General::TCP::run(%args);
}

1;
