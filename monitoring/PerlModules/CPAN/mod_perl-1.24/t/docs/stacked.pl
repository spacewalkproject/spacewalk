
package Stacked;

use vars '$i';

sub handler {
    my $r = shift;
    for my $cv (qw(two three four)) {
	$r->push_handlers(PerlHandler => \&{$cv}); 
    }
    0;
}

sub one {
    my $r = shift;
    $r->content_type("text/plain");
    $r->send_http_header;

    $i = 1;
    print "1..4\n";
    $r->print("ok $i\n");
    0;
}

sub two {
    ++$i;
    shift->print("ok $i\n");
    0;
}

sub three {
    ++$i;
    shift->write_client("ok $i\n");
    0;
}

sub four {
    ++$i;
    print "ok $i\n";
    0;
}

1;


