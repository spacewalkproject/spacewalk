
sub SSI::one {
    print "Content-type: text/html\n\n";

    print "ok 1\n<br>";
}

SSI->one;
