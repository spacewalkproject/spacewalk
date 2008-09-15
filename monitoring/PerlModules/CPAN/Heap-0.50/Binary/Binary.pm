package Heap::Binary;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);

# No names exported.
# No names available for export.
@EXPORT = ( );

$VERSION = '0.01';


# Preloaded methods go here.


# common names:
#	h	- heap head
#	i	- index of a heap value element
#	v	- user-provided value (to be) stored on the heap

################################################# debugging control

my $debug = 0;
my $validate = 0;

# enable/disable debugging output
sub debug {
    @_ ? ($debug = shift) : $debug;
}

# enable/disable validation checks on values
sub validate {
    @_ ? ($validate = shift) : $validate;
}

my $width = 3;
my $bar = ' | ';
my $corner = ' +-';
my $vfmt = "%3d";

sub set_width {
    $width = shift;
    $width = 2 if $width < 2;

    $vfmt = "%${width}d";
    $bar = $corner = ' ' x $width;
    substr($bar,-2,1) = '|';
    substr($corner,-2,2) = '+-';
}


sub hdump {
    my $h = shift;
    my $i = shift;
    my $p = shift;
    my $ch = $i*2+1;

    return if $i >= @$h;

    my $space = ' ' x $width;

    printf( "%${width}d", $h->[$i]->val );
    if( $ch+1 < @$h ) {
	hdump( $h, $ch, $p . $bar);
	print( $p, $corner );
	++$ch;
    }
    if( $ch < @$h ) {
	hdump( $h, $ch, $p . $space );
    } else {
	print "\n";
    }
}

sub heapdump {
    my $h;

    while( $h = shift ) {
	hdump $h, 0, '';
	print "\n";
    }
}

sub heapcheck {
    my $h;
    while( $h = shift ) {
	my $i;
	my $p;
	next unless @$h;
	for( $p = 0, $i = 1; $i < @$h; ++$p, ++$i ) {
	    $h->[$p]->cmp($h->[$i]) <= 0 or die "not in heap order";
	    last unless ++$i < @$h;
	    $h->[$p]->cmp($h->[$i]) <= 0 or die "not in heap order";
	}
	heapdump $h if $validate >= 2;
    }
}

################################################# forward declarations

sub moveto;
sub heapup;
sub heapdown;

################################################# heap methods

# new()                 usually Heap::Binary->new()
#	return a new empty heap
sub new {
    my $self = shift;
    my $class = ref($self) || $self;
    return bless [], $class;
}

# add($h,$v)            usually $h->add($v)
#	insert value $v into the heap
sub add {
    my $h = shift;
    my $v = shift;
    $validate && do {
	die "Method 'heap' required for element on heap"
	    unless $v->can('heap');
	die "Method 'cmp' required for element on heap"
	    unless $v->can('cmp');
    };
    heapup $h, scalar(@$h), $v;
}

# minimum($h)          usually $h->minimum
#	the smallest value is returned, but it is still left on the heap
sub minimum {
    my $h = shift;
    $h->[0];
}

# extract_minimum($h)          usually $h->extract_minimum
#	the smallest value is returned after removing it fro mthe heap
sub extract_minimum {
    my $h = shift;
    my $min = $h->[0];
    if( @$h ) {
	# there was at least one item, must decrease the heap
	$min->heap(undef);
	my $last = pop(@$h);
	if( @$h ) {
	    # $min was not the only thing left, so re-heap the
	    # remainder by over-writing position zero (where
	    # $min was) using the value popped from the end
	    heapdown $h, 0, $last;
	}
    }

    $min;
}

# absorb($h,$h2)           usually $h->absorb($h2)
#	all of the values in $h2 are inserted into $h instead, $h2 is left
#	empty.
sub absorb {
    my $h = shift;
    my $h2 = shift;
    my $v;

    foreach $v (splice @$h2, 0) {
	$h->add($v);
    }
    $h;
}

# decrease_key($h,$v)       usually $h->decrease_key($v)
#	the key value of $v has just been decreased and so it may need to
#	be percolated to a higher position in the heap
sub decrease_key {
    my $h = shift;
    my $v = shift;
    $validate && do {
	die "Method 'heap' required for element on heap"
	    unless $v->can('heap');
	die "Method 'cmp' required for element on heap"
	    unless $v->can('cmp');
    };
    my $i = $v->heap;

    heapup $h, $i, $v;
}

# delete($h,$v)       usually: $h->delete($v)
#	delete value $v from heap $h.  It must have previously been
#	add'ed to $h.
sub delete {
    my $h = shift;
    my $v = shift;
    $validate && do {
	die "Method 'heap' required for element on heap"
	    unless $v->can('heap');
	die "Method 'cmp' required for element on heap"
	    unless $v->can('cmp');
    };
    my $i = $v->heap;

    return $v unless defined $i;

    if( $i == $#$h ) {
	pop @$h;
    } else {
	my $v2 = pop @$h;
	if( $v->cmp($v2) < 0 ) {
	    heapup $h, $i, $v2;
	} else {
	    heapdown $h, $i, $v2;
	}
    }
    $v->heap(undef);
    return $v;
}


################################################# internal utility functions

# moveto($h,$i,$v)
#	place value $v at index $i in the heap $h, and update it record
#	of where it is located
sub moveto {
    my $h = shift;
    my $i = shift;
    my $v = shift;

    $h->[$i] = $v;
    $v->heap($i);
}

# heapup($h,$i,$v)
#	value $v is to be placed at index $i in heap $h, but it might
#	be smaller than some of its parents.  Keep pushing parents down
#	until a smaller parent is found or the top of the heap is reached,
#	and then place $v there.
sub heapup {
    my $h = shift;
    my $i = shift;
    my $v = shift;
    my $pi;		# parent index

    while( $i && $v->cmp($h->[$pi = int( ($i-1)/2 )]) < 0 ) {
	moveto $h, $i, $h->[$pi];
	$i = $pi;
    }

    moveto $h, $i, $v;
    $v;
}

# heapdown($h,$i,$v)
#	value $v is to be placed at index $i in heap $h, but it might
#	have children that are smaller than it is.  Keep popping the smallest
#	child up until a pair of larger children is found or a leaf node is
#	reached, and then place $v there.
sub heapdown {
    my $h = shift;
    my $i = shift;
    my $v = shift;
    my $leaf = int(@$h/2);

    while( $i < $leaf ) {
	my $j = $i*2+1;
	my $k = $j+1;

	$j = $k if $k < @$h && $h->[$k]->cmp($h->[$j]) < 0;
	if( $v->cmp($h->[$j]) > 0 ) {
	    moveto $h, $i, $h->[$j];
	    $i = $j;
	    next;
	}
	last;
    }
    moveto $h, $i, $v;
}


1;

__END__

=head1 NAME

Heap::Binary - a Perl extension for keeping data partially sorted

=head1 SYNOPSIS

  use Heap::Binary;

  $heap = Heap::Binary->new;
  # see Heap(3) for usage

=head1 DESCRIPTION

Keeps an array of elements in heap order.  The I<heap> method
of an element is used to store the index into the array that
refers to the element.

See L<Heap> for details on using this module.

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 COPYRIGHT

Copyright 1998, O'Reilly & Associates.

This code is distributed under the sme copyright as perl itself.

=head1 SEE ALSO

Heap(3), Heap::Elem(3).

=cut
