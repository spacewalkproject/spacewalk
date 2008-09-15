package Oracle::TablespaceUsage;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::Result;
use ProbeMessageCatalog;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $warnpct = $params{warnpct};
    my $critpct = $params{critpct};
    my $named_tablespace = $params{named_tablespace};

    my $msgcat  = ProbeMessageCatalog->instance();

    my $ora = $args{data_source_factory}->oracle(%params);

    my $rows = $ora->fetch('
          select free.tablespace_name,
                 total.total_bytes,
                 free.free_bytes
          from   (select   ts# as ts_id, sum(bytes) as total_bytes
                  from     v$datafile
                  group by ts# ) total,
                 (select   tablespace_name, sum(bytes) as free_bytes
                  from     dba_free_space
                  group by tablespace_name) free,
                 v$tablespace tablespace
          where  total.ts_id = tablespace.ts#
          and    tablespace.name = free.tablespace_name
          and    lower(tablespace.name) like lower(?)
    ', ['V$DATAFILE', 'DBA_FREE_SPACE', 'V$TABLESPACE'], $named_tablespace);

    $result->context("Instance $params{ora_sid} tablespaces matching \"$named_tablespace\"");

    my %pct_thresh = (warn_max => $warnpct, crit_max => $critpct);

    my $item;

    my $all_ok = check_thresholds($rows, \%pct_thresh, $result, $msgcat);

    if ($all_ok) {
        my $pct_thresh = $warnpct || $critpct;
        if ($pct_thresh > 0) {
            $result->item_ok('tablespace_pct', $pct_thresh,
                             value_format => '%.2f', 
                             label => sprintf($msgcat->oracle('tablespace_ok')),
                             units => '%');
        }
    }
}

sub check_thresholds {
    my ($rows, $pct_thresh, $result, $msgcat) = @_;

    (ref($rows) && scalar(@$rows)) or return 1;

    my $all_ok = 1;

    foreach my $row (@$rows) {
        my $tablespace = $row->{TABLESPACE_NAME};
        my $total      = $row->{TOTAL_BYTES};
        my $free       = $row->{FREE_BYTES};
        if ($total > 0) {
            my $used = $total - $free;
            my $pct = ($used / $total) * 100;

            my $total_kb = ceil($total / 1024);
            my $used_kb = ceil($used / 1024);

            $total_kb = NOCpulse::Probe::ItemStatus->add_thousands_separator($total_kb);
            $used_kb = NOCpulse::Probe::ItemStatus->add_thousands_separator($used_kb);

            my $label = sprintf($msgcat->oracle('tablespace_pct'),
                                $tablespace, $used_kb, $total_kb);
            my $item_name = "${tablespace}-percent";
            my $item = $result->item_thresholded_value($item_name, $pct, '%.2f',
                                                       $pct_thresh, 
                                                       label => $label,
                                                       units => '%',
                                                       remove_if_ok => 1);
            $all_ok = 0 if $item->not_ok;
        }
    }
    return $all_ok;
}

1;
