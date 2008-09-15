package NetworkService::FTP;

use strict;

use General::TCP;

sub run {
    my %args = @_;

    my $params = $args{params};

    $params->{service} = 'FTP';
    $params->{expect} = delete $params->{expect_content};
    if ($params->{username}) {
        $params->{send} = "USER " . $params->{username} .
          "\n\nPASS " . $params->{password} . "\nQUIT\n";
    } else {
        $params->{send} = "QUIT\n";
    }

    General::TCP::run(%args);
}

1;
