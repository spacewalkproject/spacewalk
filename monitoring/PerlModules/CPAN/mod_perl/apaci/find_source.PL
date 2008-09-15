chdir ".." unless -e 'MANIFEST';
local(*MANI);
open MANI, "MANIFEST" or die "open MANIFEST $!";

while(<MANI>) {
    next unless s,^src/modules/perl/,,; chomp;
    next unless m,.+\.(xs|c|h)$,;
    print "$_ ";
}
close MANI;

