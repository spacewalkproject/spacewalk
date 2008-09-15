package Oracle::ExtentsHelper;

use strict;

use POSIX 'ceil';
use ProbeMessageCatalog;


# Returns true value if a table owner is present in the sys.user$ table
# and owns at least one index or table.
sub owner_is_valid {
    my ($param_ref, $result, $tables_or_indexes, $ora) = @_;

    my @bind_vars = ($param_ref->{owner});

    my $check_table = $tables_or_indexes eq 'tables' ? 'all_tables' : 'all_indexes';
    my $sql;
    my $row;

    $sql = qq{
              select count(*) as "EXISTS"
              from all_users
              where username like upper(?)
             };
    $row = $ora->fetch_first($sql, ['ALL_USERS'], @bind_vars);
    if ($row->{EXISTS} == 0) {
        $result->item_unknown('No Oracle user matches "' . $param_ref->{owner} . '"');
        return 0;
    }

    $sql = qq{
              select count(*) as "OWNED"
              from $check_table
              where owner like upper(?)
             };
    $row = $ora->fetch_first($sql, [$check_table], @bind_vars);
    if ($row->{OWNED} == 0) {
        $result->item_ok('Oracle user "' . $param_ref->{owner} . '" owns no ' .
                         $tables_or_indexes);
        return 0;
    }
    return 1;
}

# Returns the results of a extents query.
sub query {
    my ($param_ref, $ora, $sql, $tables_used_arr) = @_;

    my $warn    = $param_ref->{warn};
    my $crit    = $param_ref->{critical};
    my $warnpct = $param_ref->{warnpct};
    my $critpct = $param_ref->{critpct};

    my $msgcat = ProbeMessageCatalog->instance();

    defined($warn) or defined($crit) or defined($warnpct) or defined($critpct)
      or throw NOCpulse::Probe::ConfigError($msgcat->config('ext_no_thresh'));

    my @bind_vars = ($param_ref->{owner}, $param_ref->{match_name});
    my @having_clauses = ();

    # Add the having clause for count. If the warning threshold is
    # defined, it's all we need, because it should be smaller than the critical.
    foreach my $param ($warn, $crit) {
        if (length($param)) {
            push(@bind_vars, $param);
            push(@having_clauses, 'count(*) > ?');
            last;
        }
    }
    # Same for percent.
    foreach my $param ($warnpct, $critpct) {
        if (length($param)) {
            push(@bind_vars, $param);
            push(@having_clauses, '100 * (count(*) / t.max_extents) > ?');
            last;
        }
    }

    my $having = join(' or ', @having_clauses);
    $sql .= "having $having";

    return $ora->fetch($sql, $tables_used_arr, @bind_vars);
}

# Sets the threshold results for an extents query. Returns nothing.
sub check_thresholds {
    my ($rows, $param_ref, $result) = @_;

    # No rows means nothing crossed.
    (ref($rows) && scalar(@$rows)) or return;

    my $msgcat  = ProbeMessageCatalog->instance();

    my %num_thresh = ();
    my $warn = $param_ref->{warn};
    my $crit = $param_ref->{critical};
    $num_thresh{warn_max} = $warn if length($warn);
    $num_thresh{crit_max} = $crit if length($crit);

    my %pct_thresh = ();
    my $warnpct = $param_ref->{warnpct};
    my $critpct = $param_ref->{critpct};
    $pct_thresh{warn_max} = $warnpct if length($warnpct);
    $pct_thresh{crit_max} = $critpct if length($critpct);

    foreach my $row (@$rows) {
        my $object = $row->{OWNER} . '.' . $row->{OBJECT_NAME};

        my $kb    = ceil($row->{BYTES} / 1024);
        my $max   = $row->{MAX_EXTENTS};
        my $count = $row->{EXTENT_COUNT};
        my $pct   = $row->{EXTENT_PCT_OF_MAX};

        $kb = NOCpulse::Probe::ItemStatus->add_thousands_separator($kb);

        my $count_name = "${object}-extents";
        my $count_label = sprintf($msgcat->oracle('ext_count'), $object, $kb);

        my $pct_name = "${object}-percent";
        my $pct_label = sprintf($msgcat->oracle('ext_pct'),
                                $object, $kb, $count, $max);

        my $item = $result->item_thresholded_value($count_name, $count, '%d',
                                                   \%num_thresh,
                                                   label => $count_label,
                                                   remove_if_ok => 1);

        $item = $result->item_thresholded_value($pct_name, $pct, '%.2f',
                                                \%pct_thresh, 
                                                label => $pct_label,
                                                units => '%',
                                                remove_if_ok => 1);
    }
}

# Formats the message when everything was under threshold.
sub format_all_ok {
    my ($param_ref, $result, $count_ok_label, $pct_ok_label) = @_;

    my $count_thresh = $param_ref->{warn} || $param_ref->{critical};

    if (defined($count_thresh)) {
        $result->item_ok('extent_count', $count_thresh,
                         value_format => '%d',
                         label        => $count_ok_label);
    }

    my $pct_thresh = $param_ref->{warnpct} || $param_ref->{critpct};
    if (defined($pct_thresh)) {
        $result->item_ok('extent_pct', $pct_thresh,
                         value_format => '%.2f', 
                         label        => $pct_ok_label,
                         units        => '%');
    }
}

1;
