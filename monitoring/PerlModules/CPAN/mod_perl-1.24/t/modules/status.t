use Apache::test;

my @tests = qw{
   script
   inc 
   rgysubs
   env 
   myconfig 
   hooks 
};

push @tests, qw{
    inh_tree
    isa_tree
    symdump
} if have_module "Devel::Symdump";

my $url = "/perl/perl-status";

my $tests = @tests+1;
print "1..$tests\n";
my $i = 0;

for my $loc ($url, (map "$url?$_", @tests)) {
    my $str =  fetch $loc;
    print "fetch $loc\n";
    unless($str =~ /Perl version/) {
	print $str;
	die "fetch $loc failed!\n";
    }
    die "$1\n" if $str =~ /(Internal Server Error)/;
    test ++$i, 1;
}
