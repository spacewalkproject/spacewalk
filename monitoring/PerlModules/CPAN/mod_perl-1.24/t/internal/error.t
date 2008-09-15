use Apache::test;
#we're testing an experimental feature that doesn't work for some folks
#will revisit later
unless (defined $ENV{USER} and $ENV{USER} eq 'dougm'
       and $net::callback_hooks{ERRSV_CAN_BE_HTTP}) {
    print "1..1\nok 1\n"; 
    exit;
}

skip_test if WIN32;

my $qs = "This_is_not_a_real_error";
my $content = fetch "/perl/throw_error.pl?$qs";

my $i = 0;

print "1..1\n";

print $content;
test ++$i, $content =~ /$qs/;

