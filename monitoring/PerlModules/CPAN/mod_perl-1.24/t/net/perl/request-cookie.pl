use strict;

use Apache::test;

eval {
  require Apache::Request;
  require Apache::Cookie;
  require CGI::Cookie;
};

my $r = shift;
$r->send_http_header('text/plain');

unless (have_module "Apache::Cookie" and Apache::Request->can('upload')) {
    print "1..0\n";
    print $@ if $@;
    print "$INC{'Apache/Request.pm'}\n";
    return;
}

my $i = 0;
my $tests = 33;
$tests += 7 if $r->headers_in->get("Cookie");

print "1..$tests\n";

my $letter = 'a';
for my $name (qw(one two three)) { 
    my $c = Apache::Cookie->new($r,
				-name    =>  $name,  
				-value  =>  ["bar_$name", $letter],  
				-expires =>  '+3M',  
				-path    =>  '/'  
				);  
    my $cc = CGI::Cookie->new(
			      -name    =>  $name,  
			      -value  =>  ["bar_$name", $letter],  
			      -expires =>  '+3M',  
			      -path    =>  '/'  
			      );
    ++$letter;
    $c->bake;

    my $cgi_as_string = $cc->as_string;
    my $as_string = $c->as_string;
    my $header_out = ($r->err_headers_out->get("Set-Cookie"))[-1];
    my @val = $c->value;
    print "VALUE: @val\n";
    for my $v ("string", [@val]) {
	$c->value($v);
	my @arr = $c->value;
	my $n = @arr;
	if (ref $v) {
	    test ++$i, $n == 2;
	}
	else {
	    test ++$i, $n == 1;
	}
	print "  VALUE: @arr ($n)\n";
	$c->value(\@val); #reset
    }

    for (1,0) {
	my $secure = $c->secure;
	$c->secure($_);
	print "secure: $secure\n";
    }

    print "as_string:  `$as_string'\n";
    print "header_out: `$header_out'\n";
    print "cgi cookie: `$cgi_as_string\n";  
    test ++$i, cookie_eq($as_string, $header_out);
    test ++$i, cookie_eq($as_string, $cgi_as_string);
} 

my (@Hargs) = (
	       "-name" => "key", 
	       "-values" => {qw(val two)},  
	       "-domain" => ".cp.net",
	      );
my (@Aargs) = (
	       "-name" => "key", 
	       "-values" => [qw(val two)],  
	       "-domain" => ".cp.net",
	      );
my (@Sargs) = (
	       "-name" => "key", 
	       "-values" => 'one',  
	       "-domain" => ".cp.net",
	      );

my $done_meth = 0;
for my $rv (\@Hargs, \@Aargs, \@Sargs) {
    my $c1 = Apache::Cookie->new($r, @$rv);
    my $c2 = CGI::Cookie->new(@$rv);

    for ($c1, $c2) {
	$_->expires("+3h");
    }

    for my $meth (qw(as_string name domain path expires secure)) {
	my $one = $c1->$meth() || "";
	my $two = $c2->$meth() || "";
	print "Apache::Cookie: $meth => $one\n";
	print "CGI::Cookie:    $meth => $two\n";
	test ++$i, cookie_eq($one, $two);
    } 
}

if(my $string = $r->headers_in->get('Cookie')) { 
    print $string, $/; 
    my %done = ();

    print "SCALAR context (as_string method):\n";

    print " Apache::Cookie:\n";
    my $hv = Apache::Cookie->new($r)->parse($string);
    for (sort keys %$hv) {
	print "   $_ => ", $hv->{$_}->as_string, $/;
	$done{$_} = $hv->{$_}->as_string;
    }

    print " CGI::Cookie:\n";
    $hv = CGI::Cookie->parse($string);
    for (sort keys %$hv) {
	print "   $_ => ", $hv->{$_}->as_string, $/;
	test ++$i, cookie_eq($done{$_}, $hv->{$_}->as_string);
    }

    %done = ();

    print "ARRAY context (value method):\n";
    print " Apache::Cookie:\n";
    my %hv = Apache::Cookie->new($r)->parse($string);
    my %fetch = Apache::Cookie->fetch;
    test ++$i, keys %hv == keys %fetch;

    for (sort keys %hv) {
	$done{$_} = join ", ", $hv{$_}->value;
	print "   $_ => $done{$_}\n";
    }
    print " CGI::Cookie:\n";
    %hv = CGI::Cookie->parse($string);
    for (sort keys %hv) {
	my $val = join ", ", $hv{$_}->value;
	test ++$i, cookie_eq($done{$_}, $val);
	print "   $_ => $val\n";
    }
} 
else { 
    print "NO Cookie set"; 
} 

{
    my $cgi_exp = CGI::expires('-1d', 'cookie');
    my $cookie_exp = Apache::Cookie->expires('-1d');
    print "cookie: $cookie_exp\ncgi: $cgi_exp\n";
    test ++$i, cookie_eq($cookie_exp, $cgi_exp);
}
{
    my $cgi_exp = CGI::expires('-1d', 'http');
    my $apr_exp = Apache::Request->expires('-1d');
    print "apr: $apr_exp\ncgi: $cgi_exp\n";
    test ++$i, cookie_eq($apr_exp, $cgi_exp);
}

test ++$i, 1;

sub cookie_eq {
    my($one, $two) = @_;
    unless ($one eq $two) {
	print STDERR "cookie mismatch:\n", 
	"`$one'\n", "   vs.\n", "`$two'\n";
    }
    ($one && $two) || (!$one && !$two);
}
