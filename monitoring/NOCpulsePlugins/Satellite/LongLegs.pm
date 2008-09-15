package Satellite::LongLegs;

use strict;

use NOCpulse::Log::Logger;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

my $WEBCLIENT = '/opt/home/nocpulse/libexec/LongLegs/webclient';

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command;
    my $dbg;
    if ($Log->level > 0) {
        $dbg = "--debug " . $Log->level;
    }

    $command = "$WEBCLIENT $dbg --file " . $result->probe_record->recid;

    $Log->log(1, "EXECUTING $command\n");
    my $output = `$command 2>&1`;
    my $status_code = $? >> 8;
    $Log->log(1, "WEBCLIENT status $status_code, output\n>>>$output<<<\n");

    # The last line of output is a Data::Dumper output of the item_named hash, named $items.
    my @lines = split(/\n/, $output);
    my $items;
    eval pop(@lines);
    $result->item_named($items);
}

1;
