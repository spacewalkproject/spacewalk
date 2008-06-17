package Oracle::IndexExtents;

use strict;

use ProbeMessageCatalog;
use Oracle::ExtentsHelper;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $msgcat  = ProbeMessageCatalog->instance();

    my $ora = $args{data_source_factory}->oracle(%params);

    if (Oracle::ExtentsHelper::owner_is_valid(\%params, $result, 'indexes', $ora)) {
        my $sql = qq{
                     select t.owner,
                     t.segment_name as OBJECT_NAME,
                     t.max_extents,
                     sum(x.bytes) as BYTES,
                     count(*) as EXTENT_COUNT,
                     100 * count(*) / t.max_extents as EXTENT_PCT_OF_MAX
                     from   sys.sys_dba_segs t, dba_extents x
                     where  t.owner like upper(?)
                     and    x.owner = t.owner
                     and    x.segment_name = t.segment_name
                     and    t.segment_type = 'INDEX'
                     and    t.segment_name like upper(?)
                     group by t.owner, t.segment_name, t.max_extents
                    };

        $result->context("Instance $params{ora_sid} index extents usage");

        my $rows = Oracle::ExtentsHelper::query(\%params, $ora, $sql,
                                                ['SYS.SYS_DBA_SEGS', 'DBA_EXTENTS']);

        if (defined($rows) && scalar(@$rows) > 0) {
            Oracle::ExtentsHelper::check_thresholds($rows, \%params, $result);
        } else {
            Oracle::ExtentsHelper::format_all_ok(\%params, $result, 
                                                 $msgcat->oracle('ind_ext_count_ok'),
                                                 $msgcat->oracle('ind_ext_pct_ok'));
        }
    }
}

1;
