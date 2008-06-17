
use lib '.';
use Error qw(:try);

@Error::Bad::ISA = qw(Error);

$Error::Debug = 1; # turn on verbose stacktrace

sub abc {
    try {
	try {
	    throw Error::Simple("a simple error");
	}
	catch Error::Simple with {
	    my $err = shift;
	    throw Error::Bad(-text => "some text");
	}
	except {
	    return {
		Error::Simple => sub { warn "simple" }
	    }
	}
	otherwise {
	    1;
	} finally {
	    warn "finally\n";
	};
    }
    catch Error::Bad with {
	1;
    };
}

sub def {
    unlink("not such file") or
	record Error::Simple("unlink: $!", $!) and return;
    1;
}

abc();


$x = prior Error;

print "--\n",$x->stacktrace;

unless(defined def()) {
    $x = prior Error 'main';
    print "--\n",0+$x,"\n",$x;
}

