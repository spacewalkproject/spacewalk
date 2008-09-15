eval {
    require Apache::Symbol;
};

@ISA = qw(Apache::Symbol);

sub shaken {1}

sub sturred {0}

shaken not sturred or die;

sub satan () {666} #constant subs were a nightmare to quiet down!

my $r = shift;
my $num = $r->args;

$r->send_http_header("text/plain");
print "1..2\n";
print "ok $num\n";

delete $Apache::Registry->{+__PACKAGE__};

