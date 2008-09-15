
unshift @INC, 
       -e "dirty-lib" ? '.' :
       Apache->server_root_relative("net/perl");
require "dirty-lib";
shift @INC;

unless (defined(&not_ina_package) && not_ina_package()) {
    die "%INC save/restore broken";
}

package Apache::ROOT::dirty_2dperl::dirty_2dscript_2ecgi;

use Apache::test qw(test);

print "Content-type: text/plain\n\n";

print "1..9\n";

my $i = 0;

test ++$i, not defined &subroutine;
test ++$i, not @array;
test ++$i, not %hash;
test ++$i, not defined $scalar;
test ++$i, not defined fileno(FH);
test ++$i, Outside::code() == 4;
test ++$i, keys %Outside::hash == 1;
test ++$i, @Outside::array == 1;
test ++$i, $Outside::scalar eq 'one';

