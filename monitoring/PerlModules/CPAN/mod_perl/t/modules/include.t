
use Apache::test;
skip_test if $net::callback_hooks{USE_DSO}; 
my $ua = LWP::UserAgent->new;    # create a useragent to test

print fetch($ua, "http://$net::httpserver$net::perldir/io/include.pl");
