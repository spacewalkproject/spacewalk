#!/usr/bin/perl

require Net::SSLeay;

sub provide_password {
#    ($buf,$siz,$rwflag,$pwd)=@_;
    $_[0]="1234";
    return 4;
}

Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

$ctx=Net::SSLeay::CTX_new();
Net::SSLeay::CTX_set_options($ctx,&Net::SSLeay::OP_ALL);

Net::SSLeay::CTX_set_default_passwd_cb($ctx,\&provide_password);
$r=Net::SSLeay::CTX_use_PrivateKey_file($ctx,"server_key.pem",&Net::SSLeay::FILETYPE_PEM());
if($r==0) {
    print "v‰‰r‰ avain\n";
} else {
    print "OK\n";
}
