
use Apache::test;
skip_test unless have_module "Apache::File";
print fetch "http://$net::httpserver$net::perldir/file.pl";

