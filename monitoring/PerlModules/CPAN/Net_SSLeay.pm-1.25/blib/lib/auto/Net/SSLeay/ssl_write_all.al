# NOTE: Derived from blib/lib/Net/SSLeay.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Net::SSLeay;

#line 1623 "blib/lib/Net/SSLeay.pm (autosplit into blib/lib/auto/Net/SSLeay/ssl_write_all.al)"
sub ssl_write_all {
    my $ssl = $_[0];    
    my ($data_ref, $errs);
    if (ref $_[1]) {
	$data_ref = $_[1];
    } else {
	$data_ref = \$_[1];
    }
    my ($wrote, $written, $to_write) = (0,0, blength($$data_ref));
    my $vm = $trace>2 && $linux_debug ?
	(split ' ', `cat /proc/$$/stat`)[22] : 'vm_unknown';
    warn "  write_all VM at entry=$vm\n" if $trace>2;
    while ($to_write) {
	#sleep 1; # *** DEBUG
	warn "partial `$$data_ref'\n" if $trace>3;
	$wrote = write_partial($ssl, $written, $to_write, $$data_ref);
	if (defined $wrote && ($wrote > 0)) {  # write_partial can return -1
	    $written += $wrote;
	    $to_write -= $wrote;
	}
	$vm = $trace>2 && $linux_debug ?
	    (split ' ', `cat /proc/$$/stat`)[22] : 'vm_unknown';
	warn "  written so far $wrote:$written bytes (VM=$vm)\n" if $trace>2;
	
	$errs .= print_errs('SSL_write');
	return (wantarray ? (undef, $errs) : undef) if $errs;
    }
    return wantarray ? ($written, $errs) : $written;
}

# end of Net::SSLeay::ssl_write_all
1;
