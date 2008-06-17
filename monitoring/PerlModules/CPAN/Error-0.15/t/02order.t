
use Error qw(:try);

@Error::Fatal::ISA = qw(Error);

print "1..6\n";

$num = try {
    try {
	try {
	    throw Error::Simple("ok 1\n");
	}
	catch Error::Simple with {
	    my $err = shift;
	    print $err;

	    throw Error::Fatal(-value => 4);

	    print "not ok 3\n";
	}
	catch Error::Fatal with {
	    exit(1);
	}
	finally {
	    print "ok 2\n";
	};
    } finally {
	print "ok 3\n";
    };
}
catch Error::Fatal with {
    my $err = shift;
    my $more = shift;
    $$more = 1;
    print "ok ",0+$err,"\n";
}
catch Error::Fatal with {
    my $err = shift;
    print "ok ",1+$err,"\n";
    return 6;
}
catch Error::Fatal with {
    my $err = shift;
    print "not ok ",2+$err,"\n";
};

print "ok ",$num,"\n";
