package NOCpulse::Probe::test::TestModuleMap;

use strict;

use NOCpulse::Probe::ModuleMap;

use base qw(Test::Unit::TestCase);

sub test_module {
    my $self = shift;

    my $map = NOCpulse::Probe::ModuleMap->instance();

    my $filename = '/tmp/testprobemap.ini';
    open(INI_FILE, ">$filename") or die "Cannot open ", $filename, ": $?";
    while (<DATA>) {
        print INI_FILE;
    }
    close(INI_FILE);

    my $cfg = NOCpulse::Config->new($filename);
    $self->assert(defined($cfg), "No config found in $filename\n");
    $map->_map_config($cfg);
    unlink $filename or die "Cannot delete $filename: $?";

    $self->assert(qr/^Foo::Bar::Baz$/, $map->module_for('FooBarBaz'));
    $self->assert(qr/^My::Stuff$/, $map->module_for('MyStuff'));
    $self->assert(qr/^NotThere$/, $map->module_for('NotThere'));
}

1;

__DATA__
[Modules]
FooBarBaz=Foo::Bar::Baz
MyStuff=My::Stuff
