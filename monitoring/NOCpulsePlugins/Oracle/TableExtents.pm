package Oracle::TableExtents;

use strict;

use ProbeMessageCatalog;
use Oracle::ExtentsHelper;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $msgcat  = ProbeMessageCatalog->instance();

    my $ora = $args{data_source_factory}->oracle(%params);

    if (Oracle::ExtentsHelper::owner_is_valid(\%params, $result, 'tables', $ora)) {
        my $sql = qq{
                     select t.owner,
                     t.table_name as OBJECT_NAME,
                     t.max_extents,
                     sum(x.bytes) as BYTES,
                     count(*) as EXTENT_COUNT,
                     100 * count(*) / t.max_extents as EXTENT_PCT_OF_MAX
                     from   all_tables t, dba_extents x
                     where  t.owner like upper(?)
                     and    x.owner = t.owner
                     and    x.segment_name = t.table_name
                     and    t.table_name like upper(?)
                     group by t.owner, t.table_name, t.max_extents
                    };

        $result->context("Instance $params{ora_sid} table extents usage");

        my $rows = Oracle::ExtentsHelper::query(\%params, $ora, $sql,
                                                ['ALL_TABLES', 'DBA_EXTENTS']);

        if (defined($rows) && scalar(@$rows) > 0) {
            Oracle::ExtentsHelper::check_thresholds($rows, \%params, $result);
        } else {
            Oracle::ExtentsHelper::format_all_ok(\%params, $result, 
                                                 $msgcat->oracle('tab_ext_count_ok'),
                                                 $msgcat->oracle('tab_ext_pct_ok'));
        }
    }
}

1;
