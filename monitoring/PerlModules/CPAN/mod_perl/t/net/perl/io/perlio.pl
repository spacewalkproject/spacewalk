#!/user/local/bin/perl

use Config;

#we're in Apache::Registry
#our perl is configured use sfio so we can 
#print() to STDOUT
#and
#read() from STDIN

#we've also set (per-directory config):
#PerlSendHeader On
#PerlSetupEnv   On

my $r = shift;
my $sub = "test_$ENV{QUERY_STRING}";
if (defined &{$sub}) {
    &{$sub};
}
else {
    print "Status: 200 Bottles of beer on the wall\n",
    "X-Perl-Version: $]\n";
    print "X-Perl-Script: perlio.pl\n";
    print "X-Message: hello\n";
    print "Content-type: text/plain\n\n";

    print "perlio test...\n";
    print "\$^X is $^X\n" if $^X;

    if($] >= 5.005 && $Config{usesfio} ne "true") {
	my $msg = "1234WRITEmethod";
	syswrite STDOUT, $msg, 5, 4;
	print " to STDOUT works with $] without sfio\n";
    }

    my $loc = $r->location;
    print "<Location $loc>\n";
    my(@args);

    if (@args = split(/\+/, $ENV{QUERY_STRING})) {
	print "ARGS: ",
	join(", ", map { $_ = qq{"$_"} } @args), "\n\n";
    } else {
	print "No command line arguments passed to script\n\n";
    }

    my($key,$val);
    while (($key,$val) = each %ENV) {
	print "$key=$val\n";
    }


    if ($ENV{CONTENT_LENGTH}) {
	$len = $ENV{CONTENT_LENGTH};
	read(STDIN, $content, $len);
	print "\nContent\n-------\n$content";
    }
}

sub test_1 {
    print "Content-type: text/html\n",
          "X-sub: " . "test_1\n";
    print "\r\n";
    print "1";
}

sub test_2 {
    my $msg = <<"EOF";
X-sub: test_2 
Content-type: text/html

2
EOF
    chomp $msg;
    print $msg;
}

sub test_3 {
    my $h = {
	"Content-type" => "text/plain",
	"X-sub" => "test_3",
    };
    for (keys %$h) {
	print "$_: $h->{$_}\r\n";
    }
    print "\r\n";
    print "3";
}

sub test_4 {
    my $h = {
	"Content-type" => "text/plain",
	"X-sub" => "test_4",
    };
    for (keys %$h) {
	print "$_", ": ", $h->{$_}, "\r\n";
#	print "$_", ": ", $h->{$_};
#	print "\r\n";
    }
    print "\r\n4";
}

sub test_5 {
    print <<EOF;
X-Message: parsethis
Content-type: text/html

A
B
C
D
EOF

}

