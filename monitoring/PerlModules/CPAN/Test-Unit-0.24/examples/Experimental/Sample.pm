package Experimental::Sample;

use strict;
use vars qw($VERSION @ISA @EXPORT $SIGNPOST $test_suite);

require Exporter;

@ISA = qw(Exporter);


sub new {
    my $pkg = shift;
    my $self = { @_ };


    bless($self, $pkg);

    return $self;
}

# object methods - public

sub name {
    my ( $self, $name ) = @_;
    if(  defined( $name ) ){
        $self->{name} = $name;
    }
    return $self->{name};
}


1;
__END__
