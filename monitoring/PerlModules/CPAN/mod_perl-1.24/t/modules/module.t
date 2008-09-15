use Apache::test;
use Apache::src ();

skip_test unless have_module "Apache::Module"; 

unless (Apache::src->mmn_eq) {
    skip_test;
}

print fetch "/perl/module.pl";

