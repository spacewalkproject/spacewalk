package NOCpulse::Notif::EscalatorOperation;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw(operation error)],
  list          => [qw(parameters results)];

use Storable qw(nfreeze thaw);
use NOCpulse::Log::Logger;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


#################
sub from_string {
#################
    my ($class,$string) = @_;
    my $instance;
    eval {
       $instance = thaw($string);
    };
    if ($@) {
        return undef;
    }
    return $instance
}

##########
sub init {
##########
    my $self = shift;
}

#############
sub perform {
#############
    my ($self,$escalator) = @_;
    my $op=$self->operation;
    $Log->log(9,"perform $op\n");

    my @results;
    eval {
      @results = $escalator->$op($self->parameters);
    };
    if ($@) {
      $Log->log(1,"ERROR: perform $op (", $self->parameters, "): ", $@,"\n");
      $self->error($@);
    }

    $self->results_clear;
    $self->results_push(@results);
}

##################
sub store_string {
##################
    my $self = shift;
    return nfreeze($self);
}


1;

__END__

=head1 NAME

NOCpulse::Notif::EscalatorOperation - A single operation which can be performed by an escalator.

=head1 SYNOPSIS

    use NOCpulse::Notif::EscalatorOperation;

    # Create an empty operation
    $op = NOCpulse::Notif::EscalatorOperation->new();

    # Set up an operation to register an alert
    $op->operation('register_alert');
    $op->parameters_push($filename);

    # Perform the actual operation with the escalator
    my $interface=NOCpulse::Notif::EscalatorInterface->new;
    $interface->do_operation($op);
    my @results=$op->results;

=head1 REQUIRES

Storable

=head1 EXPORTS 

Nothing.

=head1 DESCRIPTION

The C<EscalatorOperation> object encapsulates a single escalator operation, so it can be transmitted over an ipc communications mechanism, such as a socket, and be performed by an escalator process on the same machine.
=head1 CLASS METHODS

=over 4

=item new ( )

Create a new, empty EscalatorOperation.

=item from_string ( $string )

Create a new EscalatorOperation object from the given string.

=back

=head1 METHODS

=over 4

=item init ( %args ) 

Initializes the object with the given key value pairs, whose keys correspond to method names of this object.

=item operation [ ($operation) ]

Get or set the escalator operation to perform.

=item parameters 

Return the list of parameters to use when performing this operation.  (Treat as Class::MethodMaker type list.)

=item perform ( param1, param2, ... )

Perform the specified escalator operation using the given parameters, if any.

=item results [ (@results) ]

Get or set the results from having the escalator perform this operation.

=item store_string ( )

Convert this instance into a string defining the essence this object.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Escalator>
B<notif-escalator>

=cut
