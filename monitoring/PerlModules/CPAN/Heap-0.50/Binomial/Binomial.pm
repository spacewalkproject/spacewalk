package Heap::Binomial;

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


# common names
#	h	- heap head
#	el	- linkable element, contains user-provided value
#	v	- user-provided value

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
    my $el = shift;
    my $l1 = shift;
    my $b = shift;

    my $ch;

    unless( $el ) {
	print $l1, "\n";
	return;
    }

    hdump( $ch = $el->{child},
	$l1 . sprintf( $vfmt, $el->{val}->val),
	$b . $bar );

    while( $ch = $ch->{sib} ) {
	hdump( $ch, $b . $corner, $b . $bar );
    }
}

sub heapdump {
    my $h;

    while( $h = shift ) {
	my $el;

	for( $el = $$h; $el; $el = $el->{sib} ) {
	    hdump( $el, sprintf( "%02d: ", $el->{degree}), '    ' );
	}
    print "\n";
    }
}

sub bhcheck {

    my $pel = shift;
    my $pdeg = $pel->{degree};
    my $pv = $pel->{val};
    my $cel;
    for( $cel = $pel->{child}; $cel; $cel = $cel->{sib} ) {
       	die "degree not decreasing in heap"
	    unless --$pdeg == $cel->{degree};
	die "heap order not preserved"
	    unless $pv->cmp($cel->{val}) <= 0;
	bhcheck($cel);
    }
    die "degree did not decrease to zero"
	unless $pdeg == 0;
}


sub heapcheck {
    my $h;
    while( $h = shift ) {
	heapdump $h if $validate >= 2;
	my $el = $$h or next;
	my $pdeg = -1;
	for( ; $el; $el = $el->{sib} ) {
	    $el->{degree} > $pdeg
		or die "degree not increasing in list";
	    $pdeg = $el->{degree};
	    bhcheck($el);
	}
    }
}


################################################# forward declarations

sub elem;
sub elem_DESTROY;
sub link_to;
sub moveto;

################################################# heap methods


sub new {
    my $self = shift;
    my $class = ref($self) || $self;
    my $h = undef;
    bless \$h, $class;
}

sub DESTROY {
    my $h = shift;

    elem_DESTROY $$h;
}

sub add {
    my $h = shift;
    my $v = shift;
    $validate && do {
	die "Method 'heap' required for element on heap"
	    unless $v->can('heap');
	die "Method 'cmp' required for element on heap"
	    unless $v->can('cmp');
    };
    $$h = elem $v, $$h;
    $h->self_union_once;
}

sub minimum {
    my $h = shift;
    my $el = $$h or return undef;
    my $min = $el->{val};
    while( $el = $el->{sib} ) {
	$min = $el->{val}
	    if $min->cmp($el->{val}) > 0;
    }
    $min;
}

sub extract_minimum {
    my $h = shift;
    my $mel = $$h or return undef;
    my $min = $mel->{val};
    my $mpred = $h;
    my $el = $mel;
    my $pred = $h;

    # find the heap with the lowest value on it
    while( $pred = \$el->{sib}, $el = $$pred ) {
	if( $min->cmp($el->{val}) > 0 ) {
	    $min = $el->{val};
	    $mel = $el;
	    $mpred = $pred;
	}
    }

    # found it, $mpred points to it, $mel is its container, $val is it
    # unlink it from the chain
    $$mpred = $mel->{sib};

    # we're going to return the value from $mel, but all of its children
    # must be retained in the heap.  Make a second heap with the children
    # and then merge the heaps.
    $h->absorb_children($mel);

    # finally break all of its pointers, so that we won't leave any
    # memory loops when we forget about the pointer to $mel
    $mel->{p} = $mel->{child} = $mel->{sib} = $mel->{val} = undef;

    # and return the value
    $min;
}

sub absorb {
    my $h = shift;
    my $h2 = shift;

    my $dest_link = $h;
    my $el1 = $$h;
    my $el2 = $$h2;
    my $anymerge = $el1 && $el2;
    while( $el1 && $el2 ) {
	if( $el1->{degree} <= $el2->{degree} ) {
	    # advance on h's list, it's already linked
	    $dest_link = \$el1->{sib};
	    $el1 = $$dest_link;
	} else {
	    # move next h2 elem to head of h list
	    $$dest_link = $el2;
	    $dest_link = \$el2->{sib};
	    $el2 = $$dest_link;
	    $$dest_link = $el1;
	}
    }

    # if h ran out first, move rest of h2 onto end
    if( $el2 ) {
	$$dest_link = $el2;
    }

    # clean out h2, all of its elements have been move to h
    $$h2 = undef;

    # fix up h - it can have multiple items at the same degree if we
    #    actually merged two non-empty lists
    $anymerge ? $h->self_union: $h;
}

# a key has been decreased, it may have to percolate up in its heap
sub decrease_key {
    my $h = shift;
    my $v = shift;
    my $el = $v->heap or return undef;
    my $p;

    while( $p = $el->{p} ) {
	last if $v->cmp($p->{val}) >= 0;
	moveto $el, $p->{val};
	$el = $p;
    }

    moveto $el, $v;

    $v;
}

# to delete an item, we bubble it to the top of its heap (as if its key
# had been decreased to -infinity), and then remove it (as in extract_minimum)
sub delete {
    my $h = shift;
    my $v = shift;
    my $el = $v->heap or return undef;

    # bubble it to the top of its heap
    my $p;
    while( $p = $el->{p} ) {
	moveto $el, $p->{val};
	$el = $p;
    }

    # find it on the main list, to remove it and split up the children
    my $n;
    for( $p = $h; $n = $$p && $n != $el; $p = \$n->{sib} ) {
	;
    }

    # remove it from the main list
    $$p = $el->{sib};

    # put any children back onto the main list
    $h->absorb_children($el);

    return $v;
}


################################################# internal utility functions

sub elem {
    my $v = shift;
    my $sib = shift;
    my $el = {
	p	=>	undef,
	degree	=>	0,
	child	=>	undef,
	val	=>	$v,
	sib	=>	$sib,
    };
    $v->heap($el);
    $el;
}

sub elem_DESTROY {
    my $el = shift;
    my $ch;
    my $next;

    while( $el ) {
	$ch = $el->{child} and elem_DESTROY $ch;
	$next = $el->{sib};

	$el->{child} = $el->{sib} = $el->{p} = $el->{val} = undef;
	$el = $next;
    }
}

sub link_to {
    my $el = shift;
    my $p = shift;

    $el->{p} = $p;
    $el->{sib} = $p->{child};
    $p->{child} = $el;
    $p->{degree}++;
}

sub moveto {
    my $el = shift;
    my $v = shift;

    $el->{val} = $v;
    $v->heap($el);
}

# we've merged two lists in degree order.  Traverse the list and link
# together any pairs (adding 1 + 1 to get 10 in binary) to the next
# higher degree.  After such a merge, there may be a triple at the
# next degree - skip one and merge the others (adding 1 + 1 + carry
# of 1 to get 11 in binary).
sub self_union {
    my $h = shift;
    my $prev = $h;
    my $cur = $$h;
    my $next;
    my $n2;

    while( $next = $cur->{sib} ) {
	if( $cur->{degree} != $next->{degree} ) {
	    $prev = \$cur->{sib};
	    $cur = $next;
	    next;
	}

	# two or three of same degree, need to do a merge. First though,
	# skip over the leading one of there are three (it is the result
	# [carry] from the previous merge)
	if( ($n2 = $next->{sib}) && $n2->{degree} == $cur->{degree} ) {
	    $prev = \$cur->{sib};
	    $cur = $next;
	    $next = $n2;
	}

	# and now the merge
	if( $cur->{val}->cmp($next->{val}) <= 0 ) {
	    $cur->{sib} = $next->{sib};
	    link_to $next, $cur;
	} else {
	    $$prev = $next;
	    link_to $cur, $next;
	    $cur = $next;
	}
    }
    $h;
}

# we've added one element at the front, keep merging pairs until there isn't
# one of the same degree (change all the low order one bits to zero and the
# lowest order zero bit to one)
sub self_union_once {
    my $h = shift;
    my $cur = $$h;
    my $next;

    while( $next = $cur->{sib} ) {
	return if $cur->{degree} != $next->{degree};

	# merge
	if( $cur->{val}->cmp($next->{val}) <= 0 ) {
	    $cur->{sib} = $next->{sib};
	    link_to $next, $cur;
	} else {
	    $$h = $next;
	    link_to $cur, $next;
	    $cur = $next;
	}
    }
    $h;
}

# absorb all the children of an element into a heap
sub absorb_children {
    my $h = shift;
    my $el = shift;

    my $h2 = new;
    my $child = $el->{child};
    while(  $child ) {
	my $sib = $child->{sib};
	$child->{sib} = $$h2;
	$child->{p} = undef;
	$$h2 = $child;
	$child = $sib;
    }

    # merge them all in
    $h->absorb($h2);
}


1;

__END__

=head1 NAME

Heap::Binomial - a Perl extension for keeping data partially sorted

=head1 SYNOPSIS

  use Heap::Binomial;

  $heap = Heap::Binomial->new;
  # see Heap(3) for usage

=head1 DESCRIPTION

Keeps elements in heap order using a linked list of binomial trees.
The I<heap> method of an element is used to store a reference to
the node in the list that refers to the element.

See L<Heap> for details on using this module.

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 COPYRIGHT

Copyright 1998, O'Reilly & Associates.

This code is distributed under the sme copyright as perl itself.

=head1 SEE ALSO

Heap(3), Heap::Elem(3).

=cut
