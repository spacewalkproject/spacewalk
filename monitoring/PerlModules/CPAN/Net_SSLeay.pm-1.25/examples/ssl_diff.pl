#!/usr/bin/perl
# 18.6.1998, Sampo Kellomaki <sampo@iki.fi>
# Tool used to sync SSLeay.xs with ssl.h. Prints what .h has that .xs doesn't.
# Usage: examples/ssl_diff.pl *pat* SSLeay.xs /usr/local/ssl/include/ssl.h
# E.g:   examples/ssl_diff.pl SSL_CTX_ SSLeay.xs /usr/local/ssl/include/ssl.h

($pat, $xs, $h) = @ARGV;

open XS, $xs or die "Cant open .xs `$xs' ($!)\n";
foreach $_ (<XS>) {
    next unless ($name) = /^($pat.*?)\(/o;
    $xs{$name} = 1;
}
close XS;

open H, $h or die "Cant open .h `$h' ($!)\n";
foreach $_ (<H>) {
    next unless ($name) = /($pat.*?)\(/o;
    print "$name\n" unless $xs{$name};
}
close H;

__END__
