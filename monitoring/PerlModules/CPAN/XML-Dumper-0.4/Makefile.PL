use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
push(@extras,
    AUTHOR        => 'Jonathan Eisenzopf <eisen@pobox.com>'
    ) if ($ExtUtils::MakeMaker::Version >= 5.4301);
WriteMakefile(
    NAME	=> 'XML::Dumper',
    VERSION_FROM => 'Dumper.pm',
    PREREQ_PM => { XML::Parser => '2.16' } 
);
