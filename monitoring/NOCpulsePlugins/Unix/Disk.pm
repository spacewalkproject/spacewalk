package Unix::Disk;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $fs = $params{fs_0};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $df_output = $command->df();

    my($dfent, $fs_is_device);

    $dfent = $df_output->for_mountpoint($fs);

    unless ($dfent) {
      # Check is configured by device, not mountpoint
      $dfent = $df_output->for_device($fs);
      $fs_is_device = 1;

    }

    if ($dfent) {
        $dfent->convert_to_megabytes();
        if ($fs_is_device) {
          $result->context("Filesystem $fs (" . $dfent->mountpoint . ")");
        } else {
          $result->context("Filesystem $fs");
        }
        $result->metric_value('pctused',     $dfent->percent_used, '%d');
        $result->metric_value('space_avail', $dfent->available,    '%d');
        $result->metric_value('space_used',  $dfent->used,         '%d');
    } else {
        $result->user_data_not_found('Filesystem', $fs);
    }
}

1;
