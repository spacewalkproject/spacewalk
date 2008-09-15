#!/usr/bin/perl
# 19.6.1998, Sampo Kellomaki <sampo@iki.fi>
# 31.3.1999, Upgraded to OpenSSL-0.9.2b, --Sampo
# 31.7.1999, Upgraded to OpenSSL-0.9.3a, fixed depending on symlinks
#            (thanks to schinder@pobox.com) --Sampo
#
# Make a self signed cert

$dir = shift;
$openssl_path = shift || '/usr/local/ssl';
$openssl_path .= '/bin';

open (REQ, "|$openssl_path/openssl req -config $dir/req.conf "
      . "-x509 -days 36500 -new -keyout $dir/key.pem >$dir/cert.pem")
    or die "cant open req. check your path ($!)";
print REQ <<DISTINGUISHED_NAME;
XX
Net::SSLeay test land
Test City
Net::SSLeay Organization
Test Unit
127.0.0.1
sampo\@iki.fi
DISTINGUISHED_NAME
    ;
close REQ;
system "$openssl_path/openssl verify $dir/cert.pem";  # Just to check

### Prepare examples directory as certificate directory

$hash = `$openssl_path/openssl x509 -inform pem -hash -noout <$dir/cert.pem`;
chomp $hash;
unlink "$dir/$hash.0";
symlink "$dir/cert.pem", "$dir/$hash.0"
    or die "Can't symlink $dir/$hash.0 ($!)";

__END__
