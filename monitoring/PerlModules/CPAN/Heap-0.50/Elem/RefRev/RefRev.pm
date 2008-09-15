package Heap::Elem::RefRev;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader Heap::Elem);

# No names exported.
@EXPORT = ( );

# Available for export: RefRElem (to allocate a new Heap::Elem::RefRev value)
@EXPORT_OK = qw( RefRElem );

$VERSION = '0.01';


# Preloaded methods go here.

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    # two slot array, 0 for the reference value, 1 for use by Heap
    my $self = [ shift, undef ];

    return bless $self, $class;
}

sub RefRElem {	# exportable synonym for new
    Heap::Elem::RefRev->new(@_);
}

# get or set value slot
sub val {
    my $self = shift;
    @_ ? ($self->[0] = shift) : $self->[0];
}

# get or set heap slot
sub heap {
    my $self = shift;
    @_ ? ($self->[1] = shift) : $self->[1];
}

# compare two RefRev elems - the objects must have a compatible cmp method
sub cmp {
    my $self = shift;
    my $other = shift;
    return $other->[0]->cmp( $self->[0] );
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Heap::Elem::RefRev - Perl extension for reversed Object Reverence Heap Elements

=head1 SYNOPSIS

  use Heap::Elem::RefRev( RefRElem );
  use Heap::Fibonacci;

  my $heap = Heap::Fibonacci->new;
  my $elem;

  foreach $i ( 1..100 ) {
      $obj = myObject->new( $i );
      $elem = RefRElem( $obj );
      $heap->add( $elem );
  }

  while( defined( $elem = $heap->extract_minimum ) ) {
      # assume that myObject object have a method I<printable>
      print "Largest is ", $elem->val->printable, "\n";
  }

=head1 DESCRIPTION

Heap::Elem::RefRev is used to wrap object reference values into an
element that can be managed on a heap.  Each referenced object must
have a method I<cmp> which can compare itself with any of the other
objects that have references on the same heap.  These comparisons
must be consistant with normal arithmetic.  The top of the heap will
have the largest (according to I<cmp>) element still remaining.
(See L<Heap::Elem::Ref> if you want the heap to always return the
smallest element.)

The details of the Elem interface are described in L<Heap::Elem>.

The details of using a Heap interface are described in L<Heap>.

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 SEE ALSO

Heap(3), Heap::Elem(3), Heap::Elem::Ref(3).

=cut
