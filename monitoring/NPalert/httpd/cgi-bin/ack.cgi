#!/usr/bin/perl -w


use CGI;
use NOCpulse::Config;
use NOCpulse::Debug;
use strict;

my $MYURL = "http://$ENV{SERVER_NAME}$ENV{SCRIPT_NAME}"; # Apache

my $query   = new CGI;

my $output     = new NOCpulse::Debug;
my $debuglevel = $query->param('debug') || 0;
my $stdout     = $output->addstream(LEVEL => $debuglevel, APPEND => 0);

my $np_cfg       = new NOCpulse::Config;
my $cfg_file     = $np_cfg->get('notification','config_dir') . '/static/notif.ini';
my $notify_cfg   = new Config::IniFiles(-file    => $cfg_file,
                                        -nocase  => 1); 

my $SERVER_ID    = $notify_cfg->val('server','serverid'); # $server_recid is the recid of the notification server 

$|=1;



if ($query->param('show_ids')) {
  $output->dprint(0,$query->header, "\n");
  my($ids) = &get_alerts();
  $output->dprint(0,join("\n", @$ids), "\n");

} else {
  if ($query->param()) {
    &process_form($query);
  } else {
    $output->dprint(0,$query->header, "\n");
    $output->dprint(0,$query->start_html(-title=>"Notification Acknowledgement"), "\n");
    &do_start_page($query);
  }
  $output->dprint(0, $query->end_html, "\n");
  $output->close();
}


sub process_form {
  my $query = shift;
  my $send_id = $query->param('send_id');
  my $silent  = $query->param('silent');

  return unless ($send_id);

  my $ta_send_id = $send_id;
  $ta_send_id =~ s/^..//;  # Remove 2-digit notifiation server number

  my @args;
  push (@args,'-ack',$ta_send_id);
#  my ($results, $status, $command) = $TA->taexec(@args);

    if ($status) {
      #Ack failed -- generate error page
      $output->dprint(0, 
        $query->header(-status=>503),
        $query->start_html('Error'),
        $query->h2('Acknowledgement Failed'));

      if ($results =~ /Warn \*\-ack \d+ not found/ ) {
        $output->dprint(0,"Ack $send_id not found")
      } else {
        $output->dprint(0,$query->strong($results));
      }

    } elsif (!$silent) {

      #Ack succeeded -- verbose mode
      $output->dprint(0,$query->header, "\n");
      $output->dprint(0,$query->start_html(-title=>"Notification Acknowledgement"), "\n");
      $output->dprint(0, "<B>Acknowledging Send $send_id</B>\n");
      $output->dprint(0,"<PRE>\n");
      $output->dprint(0,"<B>Acknowledgement Succeeded</B><BR>\n");
      $output->dprint(0,"$results\n");
      $output->dprint(0,"<BR><HR>\n");
      $output->dprint(0,"</PRE>\n");
      &do_start_page($query);

    } else {

      #Ack succeeded -- silent mode
      $output->dprint(0,$query->header, "\n");
      $output->dprint(0,$query->start_html(-title=>"Notification Acknowledgement"), "\n");
      $output->dprint(0,"Status: $status\n");
    }
}

sub do_start_page {
  my $query = shift;

  my($ids, $table) = &get_alerts();

  if (scalar(@$ids)) {
    $output->dprint(0,$query->start_form(-method=>'GET', -action=>"$MYURL"), "\n");

    $output->dprint(0,"<B>Select a send to acknowledge:</B>  ");
    $output->dprint(0,$query->popup_menu(-name=>'send_id',
			 -values=>[@$ids],
			 -default=>$ids->[0]));
    $output->dprint(0,$query->submit(-value=>"Acknowledge"));
    $output->dprint(0,"<BR>\n");

    $output->dprint(0,"<B>Current sends:</B>\n");
    $output->dprint(0,"<UL>\n");
    $output->dprint(0,$query->start_table({-border=>1}));
    $output->dprint(0,$query->th(['SendID', 'Start', 'Dest', 'User', 'State']));

    my $row;
    foreach $row (@$table) {
      $output->dprint(0,$query->start_Tr(), "\n");
      $output->dprint(0,$query->td($row), "\n");
      $output->dprint(0,$query->end_Tr(), "\n");

    }
    $output->dprint(0,$query->end_table());
    $output->dprint(0,"</UL>\n");
    $output->dprint(0,$query->end_form,"\n");

  } else { 
    $output->dprint(0,"<B>No sends currently awaiting acknowledgement</B>\n");
  }

#  $output->dprint(0,$query->end_html(), "\n");
#  $output->close();


}



sub get_alerts {
  # Create pull-down menu
  my(@table, @ids, $id);
  my($start, $dest, $user, $state);

  my @args=qw(-show -value);
#  my ($results, $status, $command) = $TA->taexec(@args);

  foreach (split(/\n/,$results)) {
    my ($op, $data) = split(/\s+/, $_, 2);
    if ($op eq 'Send') {
      if (defined($id) && $state =~ /AckWait|acknowledgement not received/) {
        $id = sprintf("%2.2d%d",$SERVER_ID,$id);
        push(@ids, $id);
	      push(@table, [$id, $start, $dest, $user, $state]);
      }
      ($id) = (split(/\s+/, $_, 2))[1];
      ($start, $dest, $user, $state) = (undef, undef, undef, undef);
    } elsif ($op eq 'Start') {
      $start = $data || '&nbsp;';
    } elsif ($op eq 'Dest') {
      $dest = $data || '&nbsp;';
    } elsif ($op eq 'User') {
      $user = $data || '&nbsp;';
    } elsif ($op eq 'State') {
      $state = $data || '&nbsp;';
    }
  }
  if (defined($id) && $state =~ /AckWait|acknowledgement not received/) {
    $id = sprintf("%2.2d%d",$SERVER_ID,$id);
    push(@ids, $id);
    push(@table, [$id, $start, $dest, $user, $state]);
  }
  
  return (\@ids, \@table);
}
