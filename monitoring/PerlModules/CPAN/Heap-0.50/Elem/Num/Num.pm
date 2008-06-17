package Heap::Elem::Num;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader Heap::Elem);

# No names exported.
@EXPORT = ( );

# Available for export: NumElem (to allocate a new Heap::Elem::Num value)
@EXPORT_OK = qw( NumElem );

$VERSION = '0.01';


# Preloaded methods go here.

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    # two slot array, 0 for the numeric value, 1 for use by Heap
    my $self = [ shift, undef ];

    return bless $self, $class;
}

sub NumElem {	# exportable synonym for new
    Heap::Elem::Num->new(@_);
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

# compare two Num elems
sub cmp {
    my $self = shift;
    my $other = shift;
    return $self->[0] <=> $other->[0];
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Heap::Elem::Num - Perl extension for Numeric Heap Elements

=head1 SYNOPSIS

  use Heap::Elem::Num( NumElem );
  use Heap::Fibonacci;

  my $heap = Heap::Fibonacci->new;
  my $elem;

  foreach $i ( 1..100 ) {
      $elem = NumElem( $i );
      $heap->add( $elem );
  }

  while( defined( $elem = $heap->extract_minimum ) ) {
      print "Smallest is ", $elem->val, "\n";
  }

=head1 DESCRIPTION

Heap::Elem::Num is used to wrap numeric values into an element
that can be managed on a heap.  The top of the heap will have
the smallest element still remaining.  (See L<Heap::Elem::NumRev>
if you want the heap to always return the largest element.)

The details of the Elem interface are described in L<Heap::Elem>.

The details of using a Heap interface are described in L<Heap>.

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 SEE ALSO

Heap(3), Heap::Elem(3), Heap::Elem::NumRev(3).

=cut
