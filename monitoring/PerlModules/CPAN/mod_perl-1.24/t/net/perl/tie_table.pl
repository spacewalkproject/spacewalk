use Apache::test;

use strict;
my $r = shift;

$r->send_http_header("text/plain");

unless(have_module "Apache::Table") {
    print "1..0\n";
    return;
}

my $i = 0;
my $tests = 32;
print "1..$tests\n";

my $headers_in = $r->headers_in;
my $table = tied %$headers_in;

test ++$i, UNIVERSAL::isa($headers_in, 'HASH');
test ++$i, $table->isa('Apache::Table');
test ++$i, $table->get('User-Agent');
test ++$i, $r->headers_in->get('User-Agent');
test ++$i, $headers_in->{'User-Agent'};
test ++$i, $table->get('User-Agent') eq $headers_in->{'User-Agent'};
$table->merge(Accept => "application/x-perl");
test ++$i, $table->get("Accept") =~ /x-perl/;

test ++$i, not $table->get("NoChance");
test ++$i, not $headers_in->{"NoChance"};
test ++$i, keys %$headers_in > 0;

my %save = %$headers_in;

delete $headers_in->{'User-Agent'};
test ++$i, not $table->get('User-Agent');

%$headers_in = ();

test ++$i, scalar keys %$headers_in == 0;

%$headers_in = %save;

my %my_hash = (two => 2, three => 3);
@{ $r->notes }{ keys %my_hash } = (values %my_hash);

for (keys %my_hash) {
    test ++$i, scalar $r->notes->get($_);
}
$r->notes->add(three => "tre");
my(@notes) = $r->notes->get("three");
print "\@notes = @notes\n";
test ++$i, @notes == 2;

use vars qw(%Seen);

sub print_header {
    my($k,$v) = @_;
    print "DO: $k => $v\n";
    $Seen{$k}++; 
    1;
}

%Seen = (); 
$r->notes->do(\&print_header);
test ++$i, $Seen{three} == 2;
test ++$i, $Seen{two};

%Seen = ();
$r->notes->do(\&print_header, qw(three));
test ++$i, not exists $Seen{two};

sub my_as_string {
    my $r = shift;
    my @retval = ();
    push @retval, $r->the_request;

    my $str_header = sub {
	my($k, $v) = @_;
	push @retval, "$k: $v";
	1;
    };

    $r->headers_in->do($str_header);
    push @retval, "";

    push @retval, join(" ", $r->protocol, $r->status_line);
    for my $meth (qw(headers_out err_headers_out)) {
	$r->$meth()->do($str_header);
    }
    push @retval, "", "";
    join "\n", grep { defined $_ } @retval;
}

use Benchmark;
if(my_as_string($r) eq $r->as_string) {
    print "as_string match\n";
}
else {
    print "as_string MIS-match\n";
    print "-" x 20, $/; 
    print my_as_string($r);
    print "-" x 20, $/; 
    print $r->as_string;
    print "-" x 20, $/; 
}
#timethese(1_000, { 
#    Perl => sub {my $my_as_string = my_as_string($r)},
#    C    => sub {my $as_string = $r->as_string;},
#});

for my $meth (qw{
    headers_in headers_out err_headers_out notes dir_config subprocess_env
    })
{
    my $hash_ref = $r->$meth();
    my $tab = tied %$hash_ref;

    print "$meth:\n";
    while(my($k,$v) = each %$hash_ref) {
	print "$k = $v\n";
    }

    print "TOTAL: ", scalar keys %$hash_ref, "\n\n";

    test ++$i, UNIVERSAL::isa($hash_ref, 'HASH');
    test ++$i, $tab->isa('Apache::Table');
}

my $tabobj = Apache::Table->new($r);
test ++$i, $tabobj;

$tabobj->{'a'} = 1;

test ++$i, $tabobj->get('a');
