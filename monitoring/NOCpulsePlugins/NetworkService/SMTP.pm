package NetworkService::SMTP;

use strict;

use General::TCP;

sub run {
    my %args = @_;

    my $params = $args{params};

    $params->{service}    = 'SMTP';
    $params->{send}       = '';
    $params->{expect}     = '\r';
    $params->{read_bytes} = 256;
    $params->{quit}       = 'QUIT\n';

    General::TCP::run(%args);
}

1;
