package NetworkService::SSH;

use strict;

use General::TCP;

sub run {
    my %args = @_;

    my $params = $args{params};

    $params->{service} = 'SSH';
    $params->{expect}  = 'SSH';

    General::TCP::run(%args);
}

1;
