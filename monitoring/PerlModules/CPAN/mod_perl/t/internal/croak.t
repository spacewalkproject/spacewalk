use Apache::test;

my $i = 0;
print "1..12\n";

for (1..2) {
    test ++$i, simple_fetch "/death/";
    test ++$i, !simple_fetch "/death/?die";
    test ++$i, simple_fetch "/death/";

    test ++$i, simple_fetch "/death/";
    test ++$i, !simple_fetch "/death/?croak";
    test ++$i, simple_fetch "/death/";
}
