use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Spacewalk::Setup',
    AUTHOR              => 'Devan Goodwin <dgoodwin@redhat.com>',
    VERSION_FROM        => 'lib/Spacewalk/Setup.pm',
    ABSTRACT_FROM       => 'lib/Spacewalk/Setup.pm',
    PL_FILES            => {},
    EXE_FILES           => ['bin/spacewalk-setup', 'bin/cobbler-setup', 'bin/spacewalk-make-mount-points'],
    PREREQ_PM => {
        'Test::More' => 0,
    },
    MAN1PODS		=> { 'lib/Spacewalk/Setup.pm' => '$(INST_MAN1DIR)/spacewalk-setup.$(MAN1EXT)',
				'bin/cobbler-setup' => '$(INST_MAN1DIR)/cobbler-setup.$(MAN1EXT)',
			},
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Spacewalk-Setup-*' },
);

package MY;
sub tools_other {
	my $self = shift;
	my $ret = $self->SUPER::tools_other(@_);
	$ret =~ s/^(FIXIN\b.+)$/## $1\nFIXIN = \$(PERLRUN) -e 1/m;
	return $ret;
}
