#!/usr/bin/perl

# Generates the SQL statements needed to add a new command.

use strict;

use Config::IniFiles;

use constant EXEC_SQL => "/\n";

my $INDENT = '  ';
my $FIELD_NUMBER = 1;

my %PARAM_DEFAULTS =
  (
   param_type           => 'config',
   data_type_name       => 'string',
   min_value            => undef,
   max_value            => undef,
   field_widget_name    => 'text',
   field_visible_length => '40',
   field_maximum_length => '80',
  );

scalar(@ARGV) or die "Usage: $0 <command_ini_file>";

my $config = Config::IniFiles->new(-file => $ARGV[0]) or die "Cannot open $ARGV[0]: $!";
my $sql_only = $ARGV[1] eq '--sql';

my $user    = $config->val('Info', 'user');
my $bug     = $config->val('Info', 'bug');
my $release = $config->val('Info', 'release');

my $command_class = $config->val('Command', 'command_class');
my $command_id    = $config->val('Command', 'recid');

($command_id and $command_class)
  or die "Command section must include both command ID and class";


# Print the SQL for each table insertion.
print header($user, $release, $command_id, $command_class) unless $sql_only;
print command_sql($command_id, $command_class, $user, $config);
print metric_sql($command_id, $user, $command_class, $config);
print param_sql($command_id, $user, $config);
print threshold_param_sql($command_id, $user, $command_class, $config);
print os_command_xref($command_id, $user, $config);
print footer() unless $sql_only;



sub header {
    my ($user, $release, $command_id, $command_class) = @_;
    return "#!/bin/ksh
#SCHEMA_COMMENT:Add or update command $command_id, class $command_class
#RELEASE:rel_$release
#CONTACT:$user\@redhat.com
#TABLES:COMMAND COMMAND_PARAMETER COMMAND_PARAMETER_THRESHOLD OS_COMMANDS_XREF METRICS COMMAND_CLASS

sqlplus \${SCHEMA_LOGIN}\@\$DB <<'EOF'
set linesize 120
set scan on
set echo on

whenever sqlerror exit 1 rollback
";
}

sub footer {
    return "
commit;

exit;
EOF
exit
"
}


# Returns SQL to insert or update COMMAND_CLASS and COMMAND tables.
sub command_sql {
    my ($id, $class, $user, $config) = @_;

    # If there's no name, the command info is just there to define the command
    # ID for parameter updates.
    defined($config->val('Command', 'name')) or return;

    my %defaults =
      (
       last_update_user => $user,
       last_update_date => 'SYSDATE',
       enabled          => '1',
       for_host_probe   => '0',
      );

    my @cols = $config->Parameters('Command');
    add_default_cols(\@cols, keys %defaults);

    my @text = ("\n");

    push @text, "prompt command_class $command_class\n";
  # PGPORT_3:ORAFCE(DUAL) #
    push @text, "
insert into command_class(class_name) select '$command_class' from dual
where not exists (
select 1 from command_class where class_name = '$command_class')
";
    push @text, EXEC_SQL;

    push @text, "\nprompt command\n";
    my @vals = ();
    
    # Update
    push @text, "update command set\n$INDENT";
    @vals = col_values(\@cols, \%defaults, $config, 'Command', 0);
    push @text, join(",\n$INDENT", @vals), "\n";
    push @text, "where recid = $command_id\n";
    push @text, EXEC_SQL;

    # Insert
    push @text, "insert into command(\n$INDENT";
    push @text, join(",\n$INDENT", @cols), ")\n";
    push @text, "select\n$INDENT";
    @vals = col_values(\@cols, \%defaults, $config, 'Command', 1);
    push @text, join(",\n$INDENT", @vals), "\n";
    push @text, "from dual where not exists (select 1 from command where recid = $command_id)\n";
    push @text, EXEC_SQL;
    
    return join('', @text);
}

# Returns SQL to insert or update the COMMAND_PARAMETER table.
sub param_sql {
    my ($id, $user, $config) = @_;

    my %defaults = %PARAM_DEFAULTS;
    $defaults{command_id} = $id;
    $defaults{last_update_user} = $user;
    $defaults{last_update_date} = 'SYSDATE';

    my @text = ("\n");

    my @sections = $config->GroupMembers('Parameter');
    foreach my $section (@sections) {
        single_param_sql($section, \%defaults, $config, \@text);
    }
    return join('', @text);
}

# Prints SQL to insert or update the COMMAND_PARAMETER_THRESHOLD table.
sub threshold_param_sql {
    my ($id, $user, $command_class, $config) = @_;

    my %defaults = %PARAM_DEFAULTS;
    $defaults{command_id} = $id;
    $defaults{last_update_user} = $user;
    $defaults{last_update_date} = 'SYSDATE';
    $defaults{param_type} = 'threshold';

    my @text = ("\n");

    my @sections = $config->GroupMembers('ThresholdParameter');
    my @vals = ();

    foreach my $section (@sections) {
        my $param_name = single_param_sql($section, \%defaults, $config, \@text);

        push @text, "\nprompt command_parameter_threshold $param_name\n";
        my %thresh_cols = 
          ( 
           command_class => 1,
           command_id => 1,
           param_name => 1,
           param_type => 1,
           threshold_type_name => 1,
           threshold_metric_id => 1,
           last_update_user => 1,
           last_update_date => 1,
          );
        my %thresh_defaults = %defaults;
        $thresh_defaults{command_class} = $command_class;
        $thresh_defaults{param_name} = $param_name;
        my @all_cols = ('param_name', $config->Parameters($section));
        add_default_cols(\@all_cols, keys %thresh_defaults);
        my @cols = ();
        for (my $i = 0; $i < scalar(@all_cols); ++$i) {
            push(@cols, @all_cols[$i]) if exists $thresh_cols{@all_cols[$i]};
        }
        my @vals = ();

        # Update
        push @text, "update command_parameter_threshold set\n$INDENT";
        @vals = col_values(\@cols, \%thresh_defaults, $config, $section, 0);
        push @text, join(",\n$INDENT", @vals), "\n";
        push @text, "where command_id = $command_id and param_name = '$param_name'\n";
        push @text, EXEC_SQL;

        # Insert
        push @text, "insert into command_parameter_threshold(", join(",\n$INDENT", @cols), ")\n";
        push @text, "select\n$INDENT";
        @vals = col_values(\@cols, \%thresh_defaults, $config, $section, 1);
        push @text, join(",\n$INDENT", @vals), "\n";
        push @text, "from dual where not exists (\n",
        "select 1 from command_parameter_threshold\n",
        "where command_id = $command_id\n",
        "and param_name = '$param_name')\n";
        push @text, EXEC_SQL;
    }
    return join('', @text);
}

# Prints SQL to insert or update a single parameter in the COMMAND_PARAMETER table.
# Shared by print_param_sql and print_threshold_param_sql.
sub single_param_sql {
    my ($section, $defaults_hash, $config, $text_array) = @_;

    my $param_name = $section;
    $param_name =~ s/^(?:Parameter|ThresholdParameter) //;

    push @$text_array, "\n";

    my @all_cols = ('param_name', $config->Parameters($section));
    my @cols = ();
    my %remove = (field_order => 1,
                  command_class => 1,
                  threshold_type_name => 1,
                  threshold_metric_id => 1);
    foreach my $col (@all_cols) {
        push(@cols, $col) unless $remove{$col};
    }
    add_default_cols(\@cols, keys %$defaults_hash);
    $defaults_hash->{param_name} = $param_name;

    my %tmp_defaults = %$defaults_hash;
    if ($config->val($section, 'data_type_name') eq 'integer'
        || $config->val($section, 'data_type_name') eq 'float') {
        $tmp_defaults{field_visible_length} = '8' 
          unless $config->val($section, 'field_visible_length');
        $tmp_defaults{field_maximum_length} = '20'
          unless $config->val($section, 'field_maximum_length');
    }
    my @vals = ();

    push @$text_array, "prompt command_parameter $param_name\n";

    # Update
    push @$text_array, "update command_parameter set\n$INDENT";
    @vals = col_values(\@cols, \%tmp_defaults, $config, $section, 0);
    push @$text_array, join(",\n$INDENT", @vals), "\n";
    push @$text_array, "where command_id = $command_id and param_name = '$param_name'\n";
    push @$text_array, EXEC_SQL;

    # Insert
    push(@cols, 'field_order');
    $tmp_defaults{field_order} = $FIELD_NUMBER * 10;
    ++$FIELD_NUMBER;
    push @$text_array, "insert into command_parameter(\n$INDENT", 
      join(",\n$INDENT", @cols), ")\n";
    push @$text_array, "select\n$INDENT";
    @vals = col_values(\@cols, \%tmp_defaults, $config, $section, 1);
    push @$text_array, join(",\n$INDENT", @vals), "\n";
    push @$text_array, "from dual where not exists (\n",
    "select 1 from command_parameter\n",
    "where command_id = $command_id\n",
    "and param_name = '$param_name')\n";
    push @$text_array, EXEC_SQL;

    return $param_name;
}


# Prints SQL to insert or update the METRICS table.
sub metric_sql {
    my ($id, $user, $command_class, $config) = @_;

    my %defaults =
      (
       metric_id        => '',
       command_class    => $command_class,
       last_update_user => $user,
       last_update_date => 'SYSDATE',
      );

    my @text = ("\n");

    my @sections = $config->GroupMembers('Metric');
    my @vals = ();

    foreach my $section (@sections) {
        my $name = $section;
        $name =~ s/^Metric //;

        $defaults{metric_id} = $name;
        my @cols = $config->Parameters($section);
        add_default_cols(\@cols, keys %defaults);

        push @text, "\nprompt metric $name\n";

        # Update
        push @text, "update metrics set\n$INDENT";
        @vals = col_values(\@cols, \%defaults, $config, $section, 0);
        push @text, join(",\n$INDENT", @vals), "\n";
        push @text, "where metric_id = '$name' and command_class = '$command_class'\n";
        push @text, EXEC_SQL;

        # Insert
        push @text, "insert into metrics(", join(",\n$INDENT", @cols), ")\n";
        push @text, "select\n$INDENT";
        @vals = col_values(\@cols, \%defaults, $config, $section, 1);
        push @text, join(",\n$INDENT", @vals), "\n";
        push @text, "from dual where not exists (\n",
        "select 1 from metrics\n",
        "where metric_id = '$name'\n",
        "and command_class = '$command_class')\n";
        push @text, EXEC_SQL;
    }
    return join('', @text);
}

# Prints SQL to insert or update the OS_COMMANDS_XREF table.
sub os_command_xref {
    my ($id, $user, $config) = @_;

    my @cols = $config->Parameters('CommandOS');

    my @text = ("\n");

    my @sections = $config->GroupMembers('CommandOS');
    my @vals = ();

    foreach my $section (@sections) {
        my $os_name = $section;
        $os_name =~ s/^CommandOS //;

        push @text, "\nprompt os_commands_xref $os_name\n";

        # Insert (no update, there's nothing meaningful to change)
        push @text, "insert into os_commands_xref(os_id, commands_id)\n";
        push @text, "select recid, $command_id from os where os.os_name = '$os_name'\n";
        push @text, "and not exists (\n",
        "select 1 from os_commands_xref, os\n",
        "where os.recid = os_commands_xref.os_id\n",
        "and os.os_name = '$os_name'\n",
        "and os_commands_xref.commands_id = $command_id)\n";
        push @text, EXEC_SQL;
    }
    return join('', @text);
}


# Helpers

sub add_default_cols {
    my ($ini_cols, @default_cols) = @_;

    my %colmap = ();
    map { $colmap{$_} = 1 } @$ini_cols;

    foreach my $default (@default_cols) {
        push(@$ini_cols, $default) unless $colmap{$default};
    }
}

sub col_values {
    my ($column_array, $defaults_hash, $config, $section, $inserting) = @_;
    my @vals = ();
    foreach my $col (@$column_array) {
        my $val = format_value($config->val($section, $col), $col, $defaults_hash);
        push(@vals, ($inserting ? $val : "$col = $val"));
    }
    return @vals;
}

sub format_value {
    my ($val, $col, $defaults_hash) = @_;
    $val = $defaults_hash->{$col} unless defined($val);
    $val = 'NULL' if $val eq '';
    $val = "'$val'" unless $val eq 'SYSDATE' || $val eq 'NULL';
    return $val;
}
