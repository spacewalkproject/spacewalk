use Apache::test;

skip_test unless $net::callback_hooks{PERL_STACKED_HANDLERS} and
    $net::callback_hooks{PERL_FIXUP};
die "can't open http://$net::httpserver/$net::perldir/stacked\n" 
    unless simple_fetch "/stacked/test.html";
print fetch "/chain/";
