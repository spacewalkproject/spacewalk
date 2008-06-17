
use Apache::test;

my $sent = fetch "/perl/rwrite.pl";
my $i = 0;

my $string = "";
for ('A'..'Z') { 
    $string .= $_ x 1000;
}

print "1..2\n";

test ++$i, length($sent) == length($string);
test ++$i, $sent eq $string;



