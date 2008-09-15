# NOTE: Derived from blib/lib/Net/SSLeay.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Net::SSLeay;

#line 2242 "blib/lib/Net/SSLeay.pm (autosplit into blib/lib/auto/Net/SSLeay/do_httpx4.al)"
sub do_httpx4 {
    my ($page, $response, $headers, $server_cert) = &do_httpx3;
    X509_free($server_cert) if defined $server_cert;
    my %hr = ();
    for my $hh (split /\s?\n/, $headers) {
	my ($h,$v)=/^(\S+)\:\s*(.*)$/;
	push @{$hr{uc($h)}}, $v;
    }
    return ($page, $response, \%hr);
}

# end of Net::SSLeay::do_httpx4
1;
