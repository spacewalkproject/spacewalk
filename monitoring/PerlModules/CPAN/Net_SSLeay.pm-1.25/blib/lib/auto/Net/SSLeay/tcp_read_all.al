# NOTE: Derived from blib/lib/Net/SSLeay.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Net::SSLeay;

#line 1606 "blib/lib/Net/SSLeay.pm (autosplit into blib/lib/auto/Net/SSLeay/tcp_read_all.al)"
sub tcp_read_all {
    my ($how_much) = @_;
    $how_much = 2000000000 unless $how_much;
    my ($n, $got, $errs);
    my $reply = '';

    while ($how_much > 0) {
	$n = sysread(SSLCAT_S,$got,$how_much);
	warn "Read error: $! ($n,$how_much)" unless defined $n;
	last if !$n;  # EOF
	$how_much -= $n;
	debug_read(\$reply, \$got) if $trace>1;
	$reply .= $got;
    }
    return wantarray ? ($reply, $errs) : $reply;
}

# end of Net::SSLeay::tcp_read_all
1;
