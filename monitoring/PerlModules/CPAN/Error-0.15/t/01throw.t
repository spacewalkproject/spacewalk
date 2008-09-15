
use Error qw(:try);

print "1..4\n";

try {
    print "ok 1\n";
};


try {
    throw Error::Simple("ok 2\n",2);
    print "not ok 2\n";
}
catch Error::Simple with {
    my $err = shift;
    print "$err";
}
finally {
    print "ok 3\n";
};

$err = prior Error;

print "ok ",2+$err,"\n";;
