# NOTE: Derived from blib/lib/Net/SSLeay.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Net::SSLeay;

#line 2194 "blib/lib/Net/SSLeay.pm (autosplit into blib/lib/auto/Net/SSLeay/do_httpx3.al)"
sub do_httpx3 {
    my ($method, $usessl, $site, $port, $path, $headers,
	$content, $mime_type, $crt_path, $key_path) = @_;
    my ($response, $page, $h,$v);

    if ($content) {
	$mime_type = "application/x-www-form-urlencoded" unless $mime_type;
	my $len = blength($content);
	$content = "Content-Type: $mime_type$CRLF"
	    . "Content-Length: $len$CRLF$CRLF$content";
    } else {
	$content = "$CRLF$CRLF";
    }
    my $req = "$method $path HTTP/1.0$CRLF"."Host: $site:$port$CRLF"
      . (defined $headers ? $headers : '') . "Accept: */*$CRLF$content";    

    warn "do_httpx3($method,$usessl,$site:$port)" if $trace;
    my ($http, $errs, $server_cert)
	= httpx_cat($usessl, $site, $port, $req, $crt_path, $key_path);
    return (undef, "HTTP/1.0 900 NET OR SSL ERROR$CRLF$CRLF$errs") if $errs;
    
    $http = '' if !defined $http;
    ($headers, $page) = split /\s?\n\s?\n/, $http, 2;
    warn "headers >$headers< page >>$page<< http >>>$http<<<" if $trace>1;
    ($response, $headers) = split /\s?\n/, $headers, 2;
    return ($page, $response, $headers, $server_cert);
}

# end of Net::SSLeay::do_httpx3
1;
