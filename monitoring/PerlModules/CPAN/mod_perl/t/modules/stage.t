
use Apache::test;

skip_test unless have_module "Apache::Stage";

print "1..2\n";

test 1, simple_fetch "/STAGE/u1/test.html";
test 2, not simple_fetch "/STAGE/u1/nochance.html";
