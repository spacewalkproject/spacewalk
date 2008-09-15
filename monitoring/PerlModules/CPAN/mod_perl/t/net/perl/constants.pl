# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

eval { require Apache::Constants::Exports };
Apache::Constants->export(qw(HTTP_MULTIPLE_CHOICES));
use Apache::Constants qw(MODULE_MAGIC_NUMBER);
use strict qw(vars);
shift->send_http_header("text/plain");

my $version = SERVER_VERSION; 

if($version =~ /1\.1\.\d/) {
    print "1..1\nok 1\n";
    print "skipping tests against $version\n";
    die "";
}

my(%SEEN, @export, $key, $val);
while(($key,$val) = each %Apache::Constants::EXPORT_TAGS) {
    #warn "importing tag $key\n";
    Apache::Constants->import(":$key");
    push @export, grep {!$SEEN{$_}++} @$val;
}

push @export, grep {!$SEEN{$_}++} @Apache::Constants::EXPORT;
for my $sym (@Apache::Constants::EXPORT_OK) {
    next if $SEEN{$sym}++;
    Apache::Constants->import($sym) unless defined &$sym;
}

#skip some 1.3 stuff that 1.2 didn't have
my %skip = map { $_,1 } qw(DONE REMOTE_DOUBLE_REV DECLINE_CMD DIR_MAGIC_TYPE
			   SERVER_VERSION SERVER_SUBVERSION SERVER_BUILT);

#if(MODULE_MAGIC_NUMBER < 19981108) {
if(1) {
    for(qw(M_PATCH M_PROPFIND M_PROPPATCH M_MKCOL M_COPY
	   M_MOVE M_LOCK M_UNLOCK))
    {
	$skip{$_}++;
    }
}

my $tests = (1 + @export) - keys %skip; 
$tests += 1; #extras

print "1..$tests\n"; 
#$loaded = 1;
print "ok 1\n";
my $ix = 2;

my($sym);


for $sym (sort @export) {
    next if $skip{$sym};
    my $val = &$sym;
    my $name = "";
    eval {
	$name = Apache::Constants->name($val);
    };
    print defined $val ? "" : "not ", "ok $ix ($name|$sym: $val)\n";
    $ix++;
    last if $ix >= $tests;
}

my $added = HTTP_MULTIPLE_CHOICES();
print defined $added ? "" : "not ", "ok $ix\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):


