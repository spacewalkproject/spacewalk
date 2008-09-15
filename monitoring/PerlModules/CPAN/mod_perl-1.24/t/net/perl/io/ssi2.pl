
sub SSI::two {
    print "Content-type: text/html\n\n";

    print "ok 2\n<br>";
}

SSI->two;
