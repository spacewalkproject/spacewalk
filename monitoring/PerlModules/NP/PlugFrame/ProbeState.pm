
=head1 NAME

ProbeState - a class that helps provide transparent persistence of transient probe state


=head1 DESCRIPTION

ProbeState provides a mechanism for easily saving and restoring probe state info.  It 
uses the probe->name() method as a key to the data it stores, but is otherwise mostly
a slight enhancement to PersistentObject (wherein get just returns undef if it is asked to 
return something it does not know about).  

=head1 REQUIRES

Perl 5.004, NOCpulse::PersistentObject

=cut

package ProbeState;
use strict;
use vars qw(@ISA);
use NOCpulse::PersistentObject;
@ISA=qw(NOCpulse::PersistentObject);

sub AllInstancesReadOnly
{
	my ($class, @ids) = @_;
	$class = ref($class)||$class;
	# Fetch status hash from database
	if (@ids) {
	   foreach my $id (@ids) {
	      $class->loadFromDatabase($id);
	   }
	} else {
	   $class->loadFromDatabase;
	}
	my $status = ProbeState->instances;
	my @values = values(%$status);
	map { $_->set_readOnly(1) if $_ } @values;
	return $status,\@values;
}

sub instVarDefinitions
{
	my ($self,@params) = @_;
	$self->SUPER::instVarDefinitions(@params);
	$self->addInstVar('readOnly',0);
}

sub newInitializedNamed {
   my ($class,$name) = @_;
   my $state = $class->loadFromDatabase($name);
   if ($state) {
      return $state;
   } else {
      return $class->SUPER::newInitializedNamed($name);
   }
}


sub get {
   my ($self,$varname) = @_;
   if (exists($self->{$varname})) {
      return $self->{$varname}
   } else {
      return undef
   }
}

sub persist
{
	my $self = shift();
	if (! $self->get_readOnly) {
		$self->SUPER::persist;
	}
}

sub has
{
   return 1
}

sub DESTROY {
   my $self = shift();
   if ($self->databaseDirectory ne '/dev/null') {
      # Only save if there's somewhere to save to -- this avoids saving
      # meaningless state from command-line execution without a probe ID.
      $self->persist;
   }
   $self->SUPER::DESTROY;
}
