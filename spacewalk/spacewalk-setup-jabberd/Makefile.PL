use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'spacewalk-setup-jabberd',
    AUTHOR              => 'Miroslav Suchy <msuchy@redhat.com>',
    VERSION_FROM        => 'bin/spacewalk-setup-jabberd',
    ABSTRACT_FROM       => 'bin/spacewalk-setup-jabberd',
    PL_FILES            => {},
    EXE_FILES           => ['bin/spacewalk-setup-jabberd'],
    PREREQ_PM => {
        'Test::More' => 0,
    },
    MAN1PODS		=> {
				'bin/spacewalk-setup-jabberd' => '$(INST_MAN1DIR)/spacewalk-setup-jabberd.$(MAN1EXT)',
			},
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { },
);

