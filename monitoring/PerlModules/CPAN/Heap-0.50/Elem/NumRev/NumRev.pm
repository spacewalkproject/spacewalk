package Heap::Elem::NumRev;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);

# No names exported.
@EXPORT = ( );

# Available for export: NumRElem (to allocate a new Heap::Elem::NumRev value)
@EXPORT_OK = qw( NumRElem );

$VERSION = '0.01';


# Preloaded methods go here.

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    # two slot array, 0 for the numeric value, 1 for use by Heap
    my $self = [ shift, undef ];

    return bless $self, $class;
}

sub NumRElem {	# exportable synonym for new
    Heap::Elem::NumRev->new(@_);
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

# compare two NumR elems (reverse order)
sub cmp {
    my $self = shift;
    my $other = shift;
    return $other->[0] <=> $self->[0];
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Heap::Elem::NumRev - Perl extension for Reversed Numeric Heap Elements

=head1 SYNOPSIS

  use Heap::Elem::NumRev( NumRElem );
  use Heap::Fibonacci;

  my $heap = Heap::Fibonacci->new;
  my $elem;

  foreach $i ( 1..100 ) {
      $elem = NumRElem( $i );
      $heap->add( $elem );
  }

  while( defined( $elem = $heap->extract_minimum ) ) {
      print "Largest is ", $elem->val, "\n";
  }

=head1 DESCRIPTION

Heap::Elem::NumRev is used to wrap numeric values into an element
that can be managed on a heap.  The top of the heap will have
the largest element still remaining.  (See L<Heap::Elem::Num>
if you want the heap to always return the smallest element.)

The details of the Elem interface are described in L<Heap::Elem>.

The details of using a Heap interface are described in L<Heap>.

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 SEE ALSO

Heap(3), Heap::Elem(3), Heap::Elem::Num(3).

=cut
