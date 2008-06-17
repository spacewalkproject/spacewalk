package General::CheckNothing;

use strict;

use ProbeMessageCatalog;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $state   = uc($params{state});
    my $message = $params{message};

    if ($result->is_valid_state($state)) {
        $result->item_status($state, name => 'outcome', label => ' ', message => $message);
    } else {
        $result->item_unknown(sprintf(ProbeMessageCatalog->instance->config('wrong_state'),
                                      $state));
    }
}

1;
