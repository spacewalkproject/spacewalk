package Apache::ModuleConfig;

use strict;
use mod_perl ();

{
    no strict;
    $VERSION = "0.01";
    __PACKAGE__->mod_perl::boot($VERSION);
}

sub has_srv_config {
    my $file = (caller)[1];
    if($Apache::ServerStarting == 1) {
	delete $INC{$file};
    }
}

sub dir_merge {
    my($base, $add) = @_;
    my %new = ();
    @new{ keys %$base, keys %$add} = 
	(values %$base, values %$add);

    return bless \%new, ref($base);
}

1;

__END__

