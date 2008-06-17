#!/usr/bin/perl
# 19.6.1998, Sampo Kellomaki <sampo@iki.fi>
# 31.3.1999, Upgraded to OpenSSL-0.9.2b, --Sampo
# 31.7.1999, Upgraded to OpenSSL-0.9.3a, fixed depending on symlinks
#            (thanks to schinder@@pobox_.com) --Sampo
# 7.4.2001,  Upgraded to OpenSSL-0.9.6a --Sampo
# 9.11.2001, EGD patch from Mik Firestone <mik@@speed.stdio._com> --Sampo
#
# Make a self signed cert

use File::Copy;

$dir = shift;
$exe_path = shift || '/usr/local/ssl/bin/openssl';

$egd = defined( $ENV{EGD_POOL} ) ?  "-rand $ENV{EGD_POOL}" : '';

open (REQ, "|$exe_path req -config $dir/req.conf "
      . "-x509 -days 3650 -new -keyout $dir/key.pem $egd >$dir/cert.pem")
    or die "cant open req. check your path ($!)";
print REQ <<DISTINGUISHED_NAME;
XX
Net::SSLeay
test land
Test City
Net::SSLeay Organization
Test Unit
127.0.0.1
sampo\@iki.fi
DISTINGUISHED_NAME
    ;
close REQ;
system "$exe_path verify $dir/cert.pem";  # Just to check

# Generate an encrypted password too
system "$exe_path rsa -in $dir/key.pem -des -passout pass:secret -out $dir/key.pem.e"; 

### Prepare examples directory as certificate directory

$hash = `$exe_path x509 -inform pem -hash -noout <$dir/cert.pem`;
chomp $hash;
unlink "$dir/$hash.0";
copy "$dir/cert.pem", "$dir/$hash.0" or die "Can't symlink $dir/$hash.0 ($!)";

__END__
