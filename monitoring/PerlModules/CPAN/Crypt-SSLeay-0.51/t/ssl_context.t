print "1..1\n";

use Crypt::SSLeay::MainContext qw(main_ctx);

print "not " unless main_ctx() =~ /CTX/;
print "ok 1\n";

