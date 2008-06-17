
use Apache::test;

skip_test unless have_module "Devel::Symdump";

#there should _not_ be "Subroutine defined ..." warnings!

for (1,2) {
    print fetch "/perl/sym.pl?$_";
}


