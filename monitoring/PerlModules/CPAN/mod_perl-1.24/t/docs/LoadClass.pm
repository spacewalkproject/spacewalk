
package LoadClass;
#testing PERL_METHOD_HANDLERS
{
    package BaseClass;
    #so 5.005-tobe doesn't complain:
    #No such package "BaseClass" in @ISA assignment at ...
}

@ISA = qw(BaseClass);

sub method ($$) {
    my($class, $r) = @_;  
    #warn "$class->method called\n";
    0;
}

1;
__END__
