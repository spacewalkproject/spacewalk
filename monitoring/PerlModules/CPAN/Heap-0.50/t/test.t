# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..405\n"; }
END {print "not ok 1\n" unless $loaded;}
use Heap;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use Heap::Fibonacci;

use Heap::Elem::Num( NumElem );

my $count = 1;

my $heap = Heap::Fibonacci->new;

foreach( 151..200 ) {
    my $elem = NumElem( $_ );
    $heap->add( $elem );
}

foreach( 101..150 ) {
    my $elem = NumElem( $_ );
    $heap->add( $elem );
}

foreach( 51..100 ) {
    my $elem = NumElem( $_ );
    $heap->add( $elem );
}

foreach( 1..50 ) {
    my $elem = NumElem( $_ );
    $heap->add( $elem );
}

# test 2..401  - should get 1..200 in order
foreach( 1..200 ) {
    $ok = '';
    $_ == $heap->minimum->val or $ok = 'not ';
    print $ok, 'ok ', ++$count, "\n";
    $ok = '';
    $_ == $heap->extract_minimum->val or $ok = 'not ';
    print $ok, 'ok ', ++$count, "\n";
}

# test 402..405 - heap should be empty, and return undef
$ok = '';
defined( $heap->minimum ) and $ok = 'not ';
print $ok, 'ok ', ++$count, "\n";

$ok = '';
defined( $heap->extract_minimum ) and $ok = 'not ';
print $ok, 'ok ', ++$count, "\n";

$ok = '';
defined( $heap->minimum ) and $ok = 'not ';
print $ok, 'ok ', ++$count, "\n";

$ok = '';
defined( $heap->extract_minimum ) and $ok = 'not ';
print $ok, 'ok ', ++$count, "\n";

