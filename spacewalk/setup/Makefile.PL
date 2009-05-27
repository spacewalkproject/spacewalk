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
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Spacewalk-Setup-*' },
);
