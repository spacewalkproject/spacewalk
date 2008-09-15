package Crypt::SSLeay::MainContext;

# maintains a single instance of the Crypt::SSLeay::CTX class

use strict;
use Carp ();

require Crypt::SSLeay::CTX;

#my %CTX;
#for(2,3,23) {
#    my $ctx = Crypt::SSLeay::CTX->new($_);
#    $ctx->set_cipher_list($ENV{CRYPT_SSLEAY_CIPHER})
#      if $ENV{CRYPT_SSLEAY_CIPHER};    
#    $CTX{$_} = $ctx;
#}
my $ctx = &main_ctx();

sub main_ctx { 
    my $ssl_version = shift || 23;

    my $ctx = Crypt::SSLeay::CTX->new($ssl_version);
    $ctx->set_cipher_list($ENV{CRYPT_SSLEAY_CIPHER})
      if $ENV{CRYPT_SSLEAY_CIPHER};    

#    $ctx = $CTX{$ssl_version};
#    print STDERR "\n\nCTX $ctx version $ssl_version\n\n";

    $ctx;
}

my %sub_cache = ('main_ctx' => \&main_ctx );

sub import
{
    my $pkg = shift;
    my $callpkg = caller();
    my @func = @_;
    for (@func) {
        s/^&//;
        Carp::croak("Can't export $_ from $pkg") if /\W/;;
        my $sub = $sub_cache{$_};
        unless ($sub) {
            my $method = $_;
            $method =~ s/^main_ctx_//;  # optional prefix
            $sub = $sub_cache{$_} = sub { $ctx->$method(@_) };
        }
        no strict 'refs';
        *{"${callpkg}::$_"} = $sub;
    }
}

1;



