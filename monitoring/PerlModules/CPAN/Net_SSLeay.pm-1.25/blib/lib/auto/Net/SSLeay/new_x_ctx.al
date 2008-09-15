# NOTE: Derived from blib/lib/Net/SSLeay.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Net::SSLeay;

#line 1873 "blib/lib/Net/SSLeay.pm (autosplit into blib/lib/auto/Net/SSLeay/new_x_ctx.al)"
sub new_x_ctx {
    if    ($ssl_version == 2)  { $ctx = CTX_v2_new(); }
    elsif ($ssl_version == 3)  { $ctx = CTX_v3_new(); }
    elsif ($ssl_version == 10) { $ctx = CTX_tlsv1_new(); }
    else                       { $ctx = CTX_new(); }
    return $ctx;
}

# end of Net::SSLeay::new_x_ctx
1;
