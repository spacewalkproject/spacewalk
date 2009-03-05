
######################################
package NOCpulse::TroubleTicket;
######################################

use vars qw($VERSION);
$VERSION = (split(/\s+/, q$Id: TroubleTicket.pm,v 1.19 2003-07-18 02:28:18 cvs Exp $, 4))[2];
use strict;

use DBI;
use DBD::Oracle;
use NOCpulse::Config;
use NOCpulse::Debug;
use LWP::UserAgent;
use HTML::Parser;
use URI;
use URI::Escape;
use Sys::Hostname;

use Exporter;
use vars qw (@ISA @EXPORT);
@ISA=qw(Exporter);  #add exporter to your @ISA
@EXPORT=qw(LogTroubleTicket);


###################
#Global variables
my $cfg = new NOCpulse::Config;

my $USERNAME   = $cfg->get('innovate', 'user');
my $PASSWORD   = $cfg->get('innovate', 'password');
my $SUMMARYLEN = $cfg->get('innovate', 'summarylength');
my $LOGINDIR   = $cfg->get('innovate', 'logindir');

my $URL        = $cfg->get('innovate', 'url');
my $BASE       = $cfg->get('innovate', 'base_path');
my $BASEURL    = new URI("$URL$BASE");

my $DBD			   = $cfg->get('cf_db', 'dbd');
my $DBNAME		 = $cfg->get('cf_db', 'name');
my $DBUNAME		 = $cfg->get('cf_db', 'notification_username');
my $DBPASS		 = $cfg->get('cf_db', 'notification_password');

#Fixed fields
my $CATEGORY   = "Other requests";
my $PRIORITY   = "Problem Report";

#And in case Innovate tanks ...
my $SENDMAIL   = "/usr/lib/sendmail -t";
my $LASTRESORT = $cfg->get('innovate', 'lastresort');
my $MAINTAINER = $cfg->get('telalert', 'maintainer');

my $BADCHARS   = '^-_a-zA-Z0-9';

my $HOSTNAME   = hostname;
my $MAXSUMMARY = 255;
my $MAXPROBLEM = 3950;  #leave some room for innovate to put its timestamp -- 4000 is the real limit

my $UPDATE_TICKET_STATUS = 'Pending'; #Prevents innovate from pacing the NOC on updates

#my $TA = new NOCpulse::TelAlert;
my $TA;

#HTML Parser stuff
my @args    = qw(tokens tokenpos token0 tagname attr attrseq text dtext is_cdata offset length event);
my $argspec = join(",", @args);
my @events = qw(text start end declaration comment process default);


########################
 sub LogTroubleTicket { 
########################
 my ($cust,$summary,$details,$update,$update_details,$debug) = @_;
  
 my $tt = new NOCpulse::TroubleTicket;
    $tt->summary($summary);
    $tt->details($details);
    $tt->customer_id($cust);
    $tt->update($update);
    $tt->update_details($update_details);
    $tt->SetDebug($debug); 
 my $id = $tt->submit;
 return $id
}

#########
sub new {
#########
   my $class = shift;
   my $self = {};

   my $debug = new NOCpulse::Debug;
   my $stream = $debug->addstream(FILE => \*STDERR, 
                                  CONTEXT => 'literal', 
                                  LEVEL => 0);
   $self->{'debug'} = $stream;

   bless $self, $class;
}


##############
sub SetDebug {
##############
   my $self = shift;

   $self->{'debug'}->level(shift);

}


############
sub dprint {
############
   my $self = shift;

   $self->{'debug'}->dprint(@_);

}


############
sub submit {
############
   my $self = shift;

#First, log in
   $self->dprint(1, "Logging into ticketing system ...\n");
   if ($self->log_in()) {
      $self->dprint(1, "\tLogin to ticketing system successful (session ID is ", 
                    $self->session_key, ")\n");
   } else {
      $self->dprint(1, "\tLogin FAILED:  $@\n");
      $self->lastditchsend($@);
      return undef;
   }

#Then, create or update the ticket
   my ($ticketid, $last_ticket_id);

#   if ($self->update()) {    
#      $last_ticket_id = $self->setCaseNumber;
#      $ticketid       = $self->update_ticket;
#   }
   if (!$ticketid) {
    $ticketid = $self->submit_ticket($last_ticket_id) 
   }

   if ($ticketid) {
      $self->dprint(1, "\tTicket Submission successful: $ticketid\n");
   } else {
      $self->dprint(1, "\tTicket Submission FAILED: $@\n");
      $self->lastditchsend($@);
      return undef;
   }

   return $ticketid;
}


############
sub log_in {
############
   my $self = shift;

   $self->ua(NOCpulse::TroubleTicket::UserAgent->new());

   my $ua = $self->ua;
   my $logindir = uri_escape($LOGINDIR, $BADCHARS);

#Login request
   my $req = new HTTP::Request(POST => $BASEURL);
   $req->content_type('application/x-www-form-urlencoded');
   $req->content("AIMACTION=vmain&" .
                 "Login=Login&" .
                 "login.VALUE=${USERNAME}&" .
                 "password.VALUE=${PASSWORD}&" .
                 "logindir=$logindir&" .
                 "row2form_rec.VALUE=findmyrec_sub_login&" .
                 "sql_control=sql_lookup_a_user&" .
                 "skey=NOKEY");

   $self->dprint(2, "\tLogin URL:      ", $req->url(), "\n");
   $self->dprint(2, "\tLogin content:  ", $req->content(), "\n");

   my $res = $ua->request($req);

   if ($res->is_success()) {
#Create closure with $self to pass to HTML::Parser
      my $extractor = sub {
         my %p;
         @p{@args} = @_;
         if ( $p{'tagname'} eq 'a' &&
              $p{'attr'}->{'href'} =~ /AIMACTION=Submit/) {
            my $uri = new URI($p{'attr'}->{'href'});
            my $query = $uri->query();
            my %args = split(/[&=]/, $query);
            if (defined($args{'skey'})) {
               $self->session_key($args{'skey'});
            }
         }
      };

#Extract session key
      my $parser = HTML::Parser->new( api_version => 3,
                                      start_h    => [$extractor, $argspec],
                                    );

      $parser->unbroken_text(1);

      $parser->parse($res->content());

   } else {

      $@ = "Login fails:  " . $res->status_line();
      return undef;

   }

   if ($self->session_key()) {

      return $self->session_key();

   } else {

      $@ = "Login failed:  no session key";
      return undef;

   }


}


###################
sub submit_ticket {
###################
   my ($self, $last_ticket_id) = @_;

   #Last ticket id is for the case when a ticket is full and we need to open an additional
   #ticket to track additional information.  This is caused by an Innovate limitation.

   my $skey = $self->session_key();
   my $username = uri_escape($USERNAME, $BADCHARS);
   my $category = uri_escape($CATEGORY, $BADCHARS);
   my $priority = uri_escape($PRIORITY, $BADCHARS);

   my $summary  = uri_escape($self->summary(), $BADCHARS);
   if (length($summary) > $MAXSUMMARY) {
      $summary=substr($summary,0,$MAXSUMMARY);
   }
   my $customer_id = $self->customer_id();
   $customer_id = 1 unless $customer_id;

   my $details = $self->details();
   if ($last_ticket_id) {
     $details .= "\n\n(See also ticket # $last_ticket_id)";
   }
   my ($script, $line) = &calling_script();
   $details .= "\n\nREPORTED BY: $HOSTNAME: $script @ line $line";
   $details  = uri_escape($details, $BADCHARS);
   if (length($details) > $MAXPROBLEM) {
      $summary=substr($details,0,$MAXPROBLEM);
   }

#Get date
   my($mday, $mon, $year) = (localtime())[3, 4, 5];
   $mon++; $mon = 1 if ($mon == 13);
                  $year += 1900;
   my $date = sprintf("%02d/%02d/%s", $mon, $mday, $year);

#Build request
   my $pcontent = "assigned_to.VALUE=nobody&" .
                  "date_mod.VALUE=${date}&" .
                  "date_open.VALUE=${date}&" .
                  "infotype.VALUE=Ticket&" .
                  "ip_remote_user=${username}&" .
                  "submitted_by.VALUE=${username}&" .
                  "category.VALUE=${category}&" .
                  "priority_type.VALUE=${priority}&" .
                  "short_desc.VALUE=${summary}&" .
                  "problem.VALUE=${details}&" . 
                  "customer_id.VALUE=${customer_id}&" . 
                  "AIMACTION=Submit+Ticket&" . 
                  "status=Open&" .
                  "skey=${skey}";


   my $req = new HTTP::Request(POST => $BASEURL);
   $req->content($pcontent);
   $req->content_type('application/x-www-form-urlencoded');
   $req->header("referer" => "${BASEURL}?" .
                "AIMACTION=Submit&" .
                "skey=${skey}&" . 
                "ip_remote_user=${username}&" . 
                "row2form_rec.VALUE=findmyrec_sub_login&" . 
                "sql_control=sql_lookup_a_user");

   $self->dprint(2, "\tSubmission URL:      $BASEURL\n");
   $self->dprint(2, "\tSubmission content:  ", $req->content(), "\n");


#Submit ticket
   my $ua = $self->ua();
   my $res = $ua->request($req);


   my $content;
#Make sure the ticket submission was successful
   if ($res->is_success()) {
      $content = $res->content();
      my $extractor = sub {
         my %p;
         @p{@args} = @_;
         if ( $p{'text'} =~ /^HD\d+/) {
            $self->ticket_id($p{'text'});
         }
      };

#Parse content to extract ticket ID
      my $parser = HTML::Parser->new( api_version => 3,
                                      text_h     => [$extractor, $argspec],
                                    );
      $parser->unbroken_text(1);

      $parser->parse($content);


   } else {

      $@ = "Submit transaction failed:  " . $res->status_line();
      return undef;

   }

   if ($self->ticket_id()) {
      return $self->ticket_id();
   } else {
      $self->dprint(3,$content);
      $@ = "Submit fails:  couldn't find a ticket ID";
      return undef;
   }


}

#################
sub dprint_hash {
#################

   my $self = shift;
   my $level = shift;
   my %p=@_;

   foreach(keys(%p)) {
      my $temp=$p{$_};
      my $thingy=ref($temp);
      if ($thingy) {
         if ($thingy =~ /HASH/) {
            my %t=%$temp;
            $self->dprint($level,"\t$_ is a $thingy [");
            foreach(keys(%t)) {
               my $it=$t{$_};
               $self->dprint($level, "\n\t\t$_=>$it");
            }
            $self->dprint($level, "]\n");
         } else {
            my @t=@$temp;
            $self->dprint($level, "\t$_ is a $thingy (@t)\n");
         }
      } else {
         $self->dprint($level, "\t$_ = $temp\n");
      }
   }
   $self->dprint(3, "\t\teoh\n\n");

}


###################
sub load_ticket {
###################
   my $self = shift;

   $self->dprint(2, "Loading ticket.....\n");

   $self->dprint(2, "Logging in ...\n");
   $self->log_in();

   my $skey = $self->session_key();
   my $case_num = $self->case_num();
   my $username = uri_escape($USERNAME, $BADCHARS);

#Build request
   my $pcontent = "AIMACTION=row2form&" . 
                  "skey=${skey}".
                  "ip_remote_user=${username}&" .
                  "row2form_rec.VALUE=case_num^\$==${case_num}^\$";

   my $req = new HTTP::Request(POST => $BASEURL);

   $req->content($pcontent);
   $req->content_type('application/x-www-form-urlencoded');
   $req->header("referer" => "${BASEURL}?" .
                "AIMACTION=Submit&" .
                "skey=${skey}&" .
                "ip_remote_user=${username}&" .
                "row2form_rec.VALUE=findmyrec_sub_login&" .
                "sql_control=sql_lookup_a_user");

   $self->dprint(2, "\tSubmission URL:      $BASEURL\n");
   $self->dprint(2, "\tSubmission Content:      $pcontent\n");

#Submit form
   my $ua = $self->ua();
   $self->dprint(2,"Submitting request\n");
   my $res = $ua->request($req);

   my $content;
   if ($res->is_success()) {
      $self->dprint(2, "\tSUCCESS!\n");
      $content = $res->content();
      ##$self->dprint(3, "$content\n");
   } else {
      $@ = "Submit transaction failed:  " . $res->status_line();
      $self->dprint(2,$@);
      return undef;
   }

   my %newHash;
   my $last_select=undef;
   my $current_state=0;

   my $start_extractor = sub {
      my($token0, $attr)=@_;

      if ($token0 eq 'input') {
         my $name=$attr->{'name'};
         my $value=$attr->{'value'};
         $newHash{$name}=$value;
         ##$self->dprint(3,"Saving attr $name as $value for future use\n");
      }
      elsif ($token0 eq 'select') {
         $last_select=$attr->{'name'};                 
         ##$self->dprint(3,"Setting current state to 1\n");
         $current_state=1;
      }
      elsif (($current_state == 1) && ($token0=~/option/i)) {
         ##$self->dprint(3,"Setting current state to 2\n");
         $current_state=2;
      }
   } ;

   my $text_extractor = sub {
      if ($current_state == 2) {
         my $value=shift;
         $value=~s/\n//g;
         ##$self->dprint(3,"Grabbing value $last_select from option as $value\n");
         $newHash{$last_select}=$value if$last_select;
         $current_state=0;
         $last_select=undef;
      }
   } ;

   my $default_extractor = sub {
      ##$self->dprint(3,"Default extractor called\n");
      my %p;
      @p{@args} = @_;
      $self->dprint_hash(3,%p);
   } ;

   #Parse content to extract ticket info

   my $parser = HTML::Parser->new ( api_version => 3,
                                    start_h   => [$start_extractor, 'token0, attr'],
                                    text_h   => [$text_extractor, 'dtext'],
                                  );
   $parser->unbroken_text(1);

   $parser->parse($content);

   $self->dprint(3,"We built this hash....\n");
   $self->dprint_hash(3,%newHash);

   return %newHash
}

##################
sub update_ticket {
##################
  my $self=shift;

	$self->dprint(2, "update_ticket.....\n");

	my %ticketValues=$self->load_ticket();
	return undef unless %ticketValues;

#Build request

  my $descr  = $self->update_details;
     $descr  = $self->details unless $descr;
  my ($script, $line) = &calling_script();
     $descr .= " ($HOSTNAME: $script @ line $line)";

	if ($TA->updateTicketProblemWithCaseNum($self->case_num,$descr))
  {
		$@ = "Update ticket failed";
		$self->dprint(2,"$@\n");
		return undef;
	}
		$self->dprint(2,"Update ticket successful\n");
		$self->dprint(2,"$@\n");
		return $self->case_num;
}

###################
sub setCaseNumber {
###################
  # We'll cheat for this one and go directly against the Oracle database instead of through
  # the Innovate web interface.  It'll save us a bunch of time.

  # Find an already created ticket that matches this descriptio

  my $self=shift;
  my $ticketId;

  # Open a connection to the DB
  my $PrintError =  0;
  my $RaiseError =  0;
  my $AutoCommit =  0;

  my $dbh = DBI->connect("DBI:$DBD:$DBNAME", $DBUNAME, $DBPASS, { RaiseError => $RaiseError, AutoCommit => $AutoCommit });

  if (!$dbh) {
    $@ = $DBI::errstr ;  return undef }

	# Prepare the statement handle
	# #PGPORT_5:POSTGRES_VERSION_QUERY(SYSDATE
  my $sql_statement = sprintf<<EOSQL;
         SELECT MAX(case_num)
         FROM hd_problem
         WHERE short_desc = ?
   AND trunc(date_mod) + 1 >= trunc(sysdate)
EOSQL

  my $statement_handle = $dbh->prepare($sql_statement);
  if (!$statement_handle) {$@ = $DBI::errstr . ': ' . $sql_statement;  return undef }

	# Execute the query
	my $rc = $statement_handle->execute($self->summary);
	if (!$rc) {$@ = $DBI::errstr . ': ' . $sql_statement;  return undef }

	# Fetch the data, if any
  my $dataref;
	if ($statement_handle->{NUM_OF_FIELDS}) {
		$dataref = $statement_handle->fetchall_arrayref;
		if ($statement_handle->err) {$@ = $DBI::errstr . ': ' . $sql_statement;  return undef }
	}

  # Return the case number
  if (scalar(@$dataref)) {
    $ticketId = $dataref->[0]->[0];
  }

	# Close the statement handle
	$statement_handle->finish;
	if ($DBI::err) {$@ = $DBI::errstr . ': ' . $sql_statement }

  $dbh->disconnect;

	$self->case_num($ticketId);

  return $ticketId;
}

###################
sub lastditchsend {
###################
  my $self = shift;
  my $err = shift;
  my $summary = $self->summary();
  my $details = $self->details();
  my $customer_id    = $self->customer_id();
  my $update_details = $self->update_details();

  # Ticket creation failed.  Compose a mail message to
  # $LASTRESORT and defer to sendmail.
  my $msg = <<EOM;
To: $LASTRESORT
From: $MAINTAINER
Subject: Ticket creation failed!

*** $0 failed to create ticket:  
$err

*** Ticket was:
Customer Id:        $customer_id
Short Description:  $summary
Update Details: $update_details
Problem Description:
$details

*** As reported by $HOSTNAME

EOM

  open(MAIL, "|$SENDMAIL $LASTRESORT");
  print MAIL $msg;
  close(MAIL);

}

######################
sub calling_script {
######################

  # This subroutine prints the outer most script 
  # that called this routine from the call stack.

  my @layer;

  # Walk up the call stack to see how deep it is, ...
  my $i = 1;  # (Skips bottom, i.e. this sub)
  while (1) {
    my (@stuff) = caller($i);
    last unless (@stuff);
    @layer=@stuff;
    $i++;
  }

  # ... then return it.

  my ($filename, $line) = @layer[1,2];

  return ($filename, $line);

}

#####################################################
#Accessor functions (stolen from LWP::MemberMixin)
#########################################################
sub summary        { shift->_elem('summary',        @_);}
sub details        { shift->_elem('details',        @_);}
sub ua             { shift->_elem('ua',             @_);}
sub session_key    { shift->_elem('session_key',    @_);}
sub ticket_id      { shift->_elem('ticket_id',      @_);}
#########################################################
sub case_num       { shift->_elem('case_num',       @_);}
sub customer_id    { shift->_elem('customer_id',    @_);}
sub update         { shift->_elem('update',         @_);}
sub update_details { shift->_elem('update_details', @_);}
#########################################################


###########
sub _elem {
###########
#Taken from the LWP::MemberMixin module
   my($self, $elem, $val) = @_;
   my $old = $self->{$elem};
   $self->{$elem} = $val if defined $val;
   return $old;
}


##############################################################################
#PACKAGE NOCpulse::TroubleTicket::UserAgent                  #
##############################################################################

package NOCpulse::TroubleTicket::UserAgent;

use strict;
use vars qw (@ISA);
use LWP::UserAgent;

@ISA=qw(LWP::UserAgent);


#########
sub new {
#########
   my $class = shift;
   my $self = $class->SUPER::new(@_);

   bless $self, $class;
}


#Overloaded function to allow [POST -> GET] HTTP redirects
#################
sub redirect_ok {
#################
   my ($ua, $req) = @_;

   $req->method('GET');
   return 1;

}


1;



