use strict;
use Apache::test;
$|++;
my $i = 0;
my $tests = 7;

my $r = shift;
$r->send_http_header('text/plain');

eval {
    require Apache::Util;
    require HTML::Entities;
    require URI::Escape;
    require HTTP::Date;
};
if($@) {
    print "$@\n";
    print "1..0\n";
    return;
}

my $test_date_format = 0;
my $test_time_parsedate = 0;

eval {
    require Date::Format;
};

unless($@) {
    $test_date_format = 2;
    $tests += $test_date_format;
}
$@ = '';

eval {
    require Time::ParseDate;
};

unless($@) {
    $test_time_parsedate = 1;
    $tests += $test_time_parsedate;
}
$@ = '';

print "1..$tests\n";
 
for ("10321", "100666") {
    my $size = Apache::Util::size_string($_);
    test ++$i, $size;
    #print "$_ => $size\n";
}

my $html = <<EOF;
<html>
<head>
<title>Testing Escape</title>
</head>
<body>
"ok"
&how
</body>
</html>
EOF

my $txt = "No html tags in here at all";
my $etxt = Apache::Util::escape_html($txt);
test ++$i, $txt eq $etxt;

my $esc = Apache::Util::escape_html($html);
#print $esc;

my $esc_2 = HTML::Entities::encode($html);

#print $esc_2;
test ++$i, $esc eq $esc_2;
use Benchmark;

=pod
timethese(1000, {
    C => sub { my $esc = Apache::Util::escape_html($html) },
    Perl => sub { my $esc = HTML::Entities::encode($html) },
});
=cut

my $uri = "http://www.apache.org/docs/mod/mod_proxy.html?has some spaces";

my $C = Apache::Util::escape_uri($uri);
my $Perl = URI::Escape::uri_escape($uri);

print "C = $C\n";
print "Perl = $Perl\n";

#test ++$i, lc($C) eq lc($Perl); 
test ++$i, length($C) && length($Perl); 

=pod
timethese(10000, {
    C => sub { my $esc = Apache::Util::escape_uri($uri) },
    Perl => sub { my $esc = URI::Escape::uri_escape($uri) },
});  
=cut

$C = Apache::Util::ht_time();
$Perl = HTTP::Date::time2str();
my $builtin = scalar gmtime;

print "C = $C\n";
print "Perl = $Perl\n";
print "builtin = $builtin\n";

#test ++$i, lc($C) eq lc($Perl); 
test ++$i, length($C) && length($Perl); 

=pod
use Benchmark;
timethese(10000, {
    C => sub { my $d = Apache::Util::ht_time() },
    Perl => sub { my $d = HTTP::Date::time2str() },
    Perl_builtin => sub { my $d = scalar gmtime },
});  
=cut

my @formats = ("%d %b %Y %T %Z", "%a, %d %B %Y");

if($test_date_format) {
    print "Testing Date::Format\n";
    for my $fmt (@formats) {
	my $c = Apache::Util::ht_time(time, $fmt, 0);
	my $p = Date::Format::time2str($fmt, time);
	print "C=$c\nPerl=$p\n";
	#test ++$i, $c eq $p;
        test ++$i, length($c) && length($p);
    }
}
=pod
timethese(10000, {
    C => sub {
	for my $fmt (@formats) {
	    my $c = Apache::Util::ht_time(time, $fmt, 0);
	}
    },
    Perl => sub {
	for my $fmt (@formats) {
	    my $p = Date::Format::time2str($fmt, time);
	}
    },
});
=cut
=pod
Benchmark: timing 10000 iterations of C, Perl...
  C:  3 secs ( 2.64 usr  0.05 sys =  2.69 cpu)
  Perl: 21 secs (20.57 usr  0.14 sys = 20.71 cpu) 
=cut

my $date_str = "Sat, 18 Jul 1998 08:38:00 -0700";

test ++$i, Apache::Util::parsedate($date_str);

if($test_time_parsedate) {
    my $c = Apache::Util::parsedate($date_str);
    print "C says: ", scalar(localtime $c), "\n";

    my $p = Time::ParseDate::parsedate($date_str);
    print "Perl says: ", scalar(localtime $p), "\n";
    my $htt = Apache::Util::ht_time($c, $formats[-1], 0);
    print "HTT=$htt\n";
    test ++$i, 
      Apache::Util::ht_time($c, $formats[-1], 0) eq 
      Apache::Util::ht_time($p, $formats[-1], 0) 
}

=pod
timethese(10000, {
    C => sub {
	my $c = Apache::Util::parsedate($date_str);
    },
    Perl => sub {
	my $p = Time::ParseDate::parsedate($date_str);
    },
});
=cut
=pod
Benchmark: timing 10000 iterations of C, Perl...
  C:  1 secs ( 0.42 usr  0.00 sys =  0.42 cpu)
  Perl: 17 secs (16.76 usr  0.07 sys = 16.83 cpu)  
=cut

#my $hash = "aX9eP53k4DGfU";
#test ++$i, Apache::Util::validate_password("dougm", $hash);
#test ++$i, ! Apache::Util::validate_password("mguod", $hash);
