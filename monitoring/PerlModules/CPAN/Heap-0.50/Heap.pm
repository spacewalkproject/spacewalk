package Heap;

# heap is mainly here as documentation for the common heap interface.
# It defaults to Heap::Fibonacci.

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);

# No names exported.
# No names available for export.
@EXPORT = ( );

$VERSION = '0.50';


# Preloaded methods go here.

sub new {
    use Heap::Fibonacci;

    return &Heap::Fibonacci::new;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Heap - Perl extensions for keeping data partially sorted

=head1 SYNOPSIS

  use Heap;

  my $heap = Heap->new;
  my $elem;

  use Heap::Elem::Num(NumElem);

  foreach $i ( 1..100 ) {
      $elem = NumElem( $i );
      $heap->add( $elem );
  }

  while( defined( $elem = $heap->extract_maximum ) ) {
      print "Smallest is ", $elem->val, "\n";
  }

=head1 DESCRIPTION

The Heap collection of modules provide routines that manage
a heap of elements.  A heap is a partially sorted structure
that is always able to easily extract the smallest of the
elements in the structure (or the largest if a reversed compare
routine is provided).

If the collection of elements is changing dynamically, the
heap has less overhead than keeping the collection fully
sorted.

The elements must be objects as described in L<"Heap::Elem">
and all elements inserted into one heap must be mutually
compatible - either the same class exactly or else classes that
differ only in ways unrelated to the B<Heap::Elem> interface.

=head1 METHODS

=over 4

=item $heap = HeapClass::new(); $heap2 = $heap1->new();

Returns a new heap object of the specified (sub-)class.
This is often used as a subroutine instead of a method,
of course.

=item $heap->DESTROY

Ensures that no internal circular data references remain.
Some variants of Heap ignore this (they have no such references).
Heap users normally need not worry about it, DESTROY is automatically
invoked when the heap reference goes out of scope.

=item $heap->add($elem)

Add an element to the heap.

=item $elem = $heap->minimum

Return the top element on the heap.  It is B<not> removed from
the heap but will remain at the top.  It will be the smallest
element on the heap (unless a reversed cmp function is being
used, in which case it will be the largest).  Returns I<undef>
if the heap is empty.

=item $elem = $heap->extract_minimum

Delete the top element from the heap and return it.  Returns
I<undef> if the heap was empty.

=item $heap1->absorb($heap2)

Merge all of the elements from I<$heap2> into I<$heap1>.
This will leave I<$heap2> empty.

=item $heap1->decrease_key($elem)

The element will be moved closed to the top of the
heap if it is now smaller than any higher parent elements.
The user must have changed the value of I<$elem> before
I<decrease_key> is called.  Only a decrease is permitted.
(This is a decrease according to the I<cmp> function - if it
is a reversed order comparison, then you are only permitted
to increase the value of the element.  To be pedantic, you
may only use I<decrease_key> if
I<$elem->cmp($elem_original) <= 0> if I<$elem_original> were
an elem with the value that I<$elem> had before it was
I<decreased>.)

=item $elem = $heap->delete($elem)

The element is removed from the heap (whether it is at
the top or not).

=back

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 COPYRIGHT

Copyright 1998, O'Reilly & Associates.

This code is distributed under the same copyright terms as perl
itself.

=head1 SEE ALSO

Heap::Elem(3), Heap::Binary(3), Heap::Binomial(3), Heap::Fibonacci(3).

=cut
