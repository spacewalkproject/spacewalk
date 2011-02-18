package test::TestAcknowledgement;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Acknowledgement;
use Data::Dumper;
use NOCpulse::Log::Logger;

use vars qw($one $two $three $four $five $six $seven $eight $nine $ten $eleven $twelve);

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

my $MODULE = 'NOCpulse::Notif::Acknowledgement';

my $directory = "/tmp/$$";
 
my $address = 'nobody@nocpulse.com';

# Test file contents

my @files=qw(one two three four five six seven eight nine ten eleven twelve);

my %hash;
$one = <<ONE;
To: rogerthat01\@alerts.nocpulse.net 
Subject: Undeliverable: CRITICAL: : yournamehere.org at 07:24 GMT
Date: Sun, 21 Jul 2002 07:10:15 -0400
From: System Administrator <postmaster\@TestOrg.com>
This message is in MIME format. Since your mail reader does not understand
 this format, some or all of this message may not be legible.
 
 ------_=_NextPart_000_01C230A7.4007C85E
 Content-Type: text/plain;
        charset="iso-8859-1"
 
 Your message
 
   To:      $address
   Subject: CRITICAL: : yournamehere.org at 07:24 GMT
   Sent:    Sun, 21 Jul 2002 07:10:15 -0400
 
 did not reach the following recipient(s):
 
 5303303282\@TESTORG.COM on Sun, 21 Jul 2002 07:10:13 -0400
     The recipient name is not recognized
        The MTS-ID of the original message is: c=us;a= ;p=testorg
 communica;l=ATLNTGW010207211110PDPS1CMY
     MSEXCH:IMS:TestOrg Communications, Inc.:TESTORGUS:ATLNTGW01 0 (000C05A6)
 Unknown Recipient
 
 
 
 ------_=_NextPart_000_01C230A7.4007C85E
 Content-Type: message/rfc822
 
 Message-ID: <200207211110.g6LBAFe20891\@gazelle.nocpulse.com>
 From: Red Hat Command Center Notification <rogerthat01\@alerts.nocpulse.com>
 To: $address
 Subject: CRITICAL: : yournamehere.org at 07:24 GMT
 Date: Sun, 21 Jul 2002 07:10:15 -0400
 MIME-Version: 1.0
 X-Mailer: Internet Mail Service (5.5.2653.19)
 X-MS-Embedded-Report: 
 Content-Type: text/plain;
        charset="iso-8859-1"
 
 This is Red Hat Command Center event notification 016rz5qj.
 
 Time:      Sun Jul 21, 07:24:58 GMT
 State:     CRITICAL
 Host:       ()
 Check:     yournamehere.o
 
 ------_=_NextPart_000_01C230A7.4007C85E--
ONE

$two = <<TWO;
To: rogerthat01\@alerts.nocpulse.net 
Subject: Returned mail: see transcript for details
Date: Date: Fri, 19 Jul 2002 07:35:18 GMT
From: Mail Delivery Subsystem <MAILER-DAEMON\@tarantula.nocpulse.com>
This is a MIME-encapsulated message
 
 --g6J7ZIc26005.1027064118/tarantula.nocpulse.com
 
 The original message was received at Fri, 19 Jul 2002 07:35:18 GMT
 from horse.nocpulse.com [10.255.254.32]
 
    ----- The following addresses had permanent fatal errors -----
 <$address>
     (reason: 550 <$address>... User unknown)
 
    ----- Transcript of session follows -----
 ... while talking to testorg.com.testorg.mail1.psmtp.com.:
 >>> RCPT To:<$address>
 <<< 550 <$address>... User unknown
 550 5.1.1 <$address>... User unknown
 
 --g6J7ZIc26005.1027064118/tarantula.nocpulse.com
 Content-Type: message/delivery-status
 
 Reporting-MTA: dns; tarantula.nocpulse.com
 Received-From-MTA: DNS; horse.nocpulse.com
 Arrival-Date: Fri, 19 Jul 2002 07:35:18 GMT
 
 Final-Recipient: RFC822; $address
 Action: failed
 Status: 5.1.1
 Remote-MTA: DNS; testorg.com.testorg.mail1.psmtp.com
 Diagnostic-Code: SMTP; 550 <$address>... User unknown
 Last-Attempt-Date: Fri, 19 Jul 2002 07:35:18 GMT
 
 --g6J7ZIc26005.1027064118/tarantula.nocpulse.com
 Content-Type: message/rfc822
 
 Return-Path: <rogerthat01\@nocpulse.com>
 Received: from horse.nocpulse.com (horse.nocpulse.com [10.255.254.32])
        by tarantula.nocpulse.com (8.11.6/8.11.4) with SMTP id g6J7ZIc26001
        for <$address>; Fri, 19 Jul 2002 07:35:18 GMT
 Date: Fri, 19 Jul 2002 07:35:18 GMT
 Message-Id: <200207190735.g6J7ZIc26001\@tarantula.nocpulse.com>
 To: $address
 From: "Red Hat Command Center Notification" <rogerthat01\@nocpulse.com>
 Precedence: special-delivery
 Priority: urgent
 Subject: CRITICAL: testprod5dbu: Oracle: Disk Sort Ratio at 0
 
 This is Red Hat Command Center event notification 01xh0rm5.
 
 Time:      Fri Jul 19, 07:35:08 GMT
 State:     CRITICAL
 Host:      testprod5dbu (192.168.0.24)
 Check:     Oracle: Disk Sort Ratio
 Message:     Instance USRDEV: Disk sort ratio 31% (above critical threshold of 10%); Memory sort rate 5/min; 
Disk sort rate 2/min
 Notification #4 for Disk sort ratio
 
 Run from:  Testorg-NOC1A
 
 To acknowledge, reply to this message with this subject line:
      ACK 01xh0rm5
 
 To immediately escalate, reply to this message with this subject line:
      NACK 01xh0rm5
 
 --g6J7ZIc26005.1027064118/tarantula.nocpulse.com--
TWO

$three= <<THREE;
To: rogerthat01\@alerts.nocpulse.net 
Subject: Returned mail: Unable to deliver.  The message was not sent.
Date: Tue, 23 Jul 2002 05:42:42 GMT
From: Mail Delivery Subsystem <MAILER-DAEMON\@marsemail02.yourorg.com>
This is a MIME-encapsulated message
 
 --AAA10956.1027402984/marsemail02.yourorg.com
 
 The original message was received at Tue, 23 Jul 2002 00:42:42 -0500 (CDT)
 from gazelle.nocpulse.com [63.121.136.42]
 
    ----- The following addresses had permanent fatal errors -----
 <$address>
 
    ----- Transcript of session follows -----
 554 <$address>... Unable to deliver.  The message was not sent.
 
 --AAA10956.1027402984/marsemail02.yourorg.com
 Content-Type: message/delivery-status
 
 Reporting-MTA: dns; marsemail02.yourorg.com
 Received-From-MTA: DNS; gazelle.nocpulse.com
 Arrival-Date: Tue, 23 Jul 2002 00:42:42 -0500 (CDT)
 
 Final-Recipient: RFC822; 3845351\@yourorg
 Action: failed
 Status: 5.5.4
 Last-Attempt-Date: Tue, 23 Jul 2002 00:43:04 -0500 (CDT)
 
 --AAA10956.1027402984/marsemail02.yourorg.com
 Content-Type: message/rfc822
 
 Received: from gazelle.nocpulse.com (gazelle.nocpulse.com [63.121.136.42])
        by marsemail02.yourorg.com (8.9.3/8.9.3) with ESMTP id AAA28549
        for <$address>; Tue, 23 Jul 2002 00:42:42 -0500 (CDT)
 Content-Type: text/plain
 Received: from horse.nocpulse.com (horse.nocpulse.com [10.255.254.32])
        by gazelle.nocpulse.com (8.11.6/8.11.4) with SMTP id g6N5gge00303
        for <$address>; Tue, 23 Jul 2002 05:42:42 GMT
 Date: Tue, 23 Jul 2002 05:42:42 GMT
 Message-Id: <200207230542.g6N5gge00303\@gazelle.nocpulse.com>
 To: $address
 From: "Red Hat Command Center Notification" <rogerthat01\@alerts.nocpulse.com>
 Precedence: special-delivery
 Priority: urgent
 Subject: CRITICAL: : NET TestProduct: Install Cluster at 05:4
 
 This is Red Hat Command Center event notification 01lk0tl8.
 
 Time:      Tue Jul 23, 05:42:35 GMT
 State:     CRITICAL
 Host:       ()
 Check:     NET TestProduct: Install Cluster
 Message:     NET TestProduct: Install Cluster problem: 500 - Can_t connect to install.videosnap.testorg.net:80
 (Operation now in progress); NET TestProduct: Install Cluster total time 30.0432 sec (above critical threshold 
of 30.0000 sec)
 Notification #2 for NET TestProduct: Install Cluster total time
 
 Run from:  testorg.com
 
 To acknowledge, reply to this message with this subject line:
      ACK 01lk0tl8
 
 To immediately escalate, reply to this message with this subject line:
      NACK 01lk0tl8
 
 --AAA10956.1027402984/marsemail02.yourorg.com--
THREE

$four = <<FOUR;
To: rogerthat01\@alerts.nocpulse.net 
Subject: Returned mail: Service unavailable
From: MAILER-DAEMON\@uunet.uu.net (Mail Delivery Subsystem)
Date: Wed, 24 Jul 2002 00:14:27 GMT
This is a MIME-encapsulated message
 
 --QQmyuy11323.1027469679/mr0.ash.ops.us.uu.net
 
 The original message was received at Wed, 24 Jul 2002 00:14:38 GMT
 from gazelle.nocpulse.com [63.121.136.42]
 
    ----- The following addresses had permanent fatal errors -----
 <$address>
 
    ----- Transcript of session follows -----
 553 <$address>... unauthorized relay traffic prohibited
 554 <$address>... Service unavailable
 
 --QQmyuy11323.1027469679/mr0.ash.ops.us.uu.net
 Content-Type: message/delivery-status
 
 Reporting-MTA: dns; mr0.ash.ops.us.uu.net
 Received-From-MTA: dns; gazelle.nocpulse.com
 Arrival-Date: Wed, 24 Jul 2002 00:14:38 GMT
 
 Final-Recipient: rfc822; $address
 Action: failed
 Status: 5.5.0
 Remote-MTA: dns; gazelle.nocpulse.com
 Last-Attempt-Date: Wed, 24 Jul 2002 00:14:39 GMT
 
 --QQmyuy11323.1027469679/mr0.ash.ops.us.uu.net
 Content-Type: message/rfc822
 
 Return-Path: <rogerthat01\@alerts.nocpulse.com>
 Received: from gazelle.nocpulse.com by mr0.ash.ops.us.uu.net with ESMTP 
        (peer crosschecked as: gazelle.nocpulse.com [63.121.136.42])
        id QQmyuy11304
        for <$address>; Wed, 24 Jul 2002 00:14:38 GMT
 Received: from horse.nocpulse.com (horse.nocpulse.com [10.255.254.32])
        by gazelle.nocpulse.com (8.11.6/8.11.4) with SMTP id g6O0ERe17937
        for <$address>; Wed, 24 Jul 2002 00:14:27 GMT
 Date: Wed, 24 Jul 2002 00:14:27 GMT
 Message-Id: <200207240014.g6O0ERe17937\@gazelle.nocpulse.com>
 To: $address
 From: "Red Hat Command Center Notification" <rogerthat01\@alerts.nocpulse.com>
 Precedence: special-delivery
 Priority: urgent
 Subject: CRITICAL: testorg-smtp3: Network Services: Mail Tran
 
 This is Red Hat Command Center event notification 01xt68px.
 
 Time:      Wed Jul 24, 00:14:11 GMT
 State:     CRITICAL
 Host:      testorg-smtp3 (192.168.0.24)
 Check:     N
 Message:    etwork Services: Mail Transfer (SMTP) SMTP port 25: Transport endpoint is not connected 
 
 Run from:  testorg-sourcing02
 
 To acknowledge, reply to this message with this subject line:
      ACK 01xt68px
 
 To immediately escalate, reply to this message with this subject line:
      NACK 01xt68px
 
 --QQmyuy11323.1027469679/mr0.ash.ops.us.uu.net--
FOUR

$five = <<FIVE;
Date: Fri, 19 Jul 2002 00:22:02 -0400
From: \"your.name\" <$address>
Subject: ACK 01gk1ncf



Red Hat Command Center Notification wrote:

> This is Red Hat Command Center event notification 01gk1ncf.
>
> Time:      Fri Jul 19, 04:08:40 GMT
> State:     CRITICAL
> Host:      yo (192.168.0.24)
> Check:     Network Services: Web server (HTTP)
> Message:     HTTP request failed: 500 Can_t connect to www.yourorganization.com:80 (Transport endpoint is no
connected)
>
> Run from:  testorg01
>
> To acknowledge, reply to this message with this subject line:
>      ACK 01gk1ncf
>
> To immediately escalate, reply to this message with this subject line:
>      NACK 01gk1ncf
FIVE

$six = <<SIX;
Date: Wed, 24 Jul 2002 08:29:40 -0700
From: \"Jane R. Customer\" <$address>
Subject: NACK 01x037j4



--In the common tongue, the sage Red Hat Command Center Notification said:

> This is Red Hat Command Center event notification 01x037j4.
>
> Time:      Wed Jul 24, 15:25:22 GMT
> State:     CRITICAL
> Host:       ()
> Check:     testcorp Web  Monitor
> Message:     Login total time 26.5502 sec (above critical threshold of
> 10.0000 sec)
>
> Run from:  testcorp-NOC1A
>
> To acknowledge, reply to this message with this subject line:
>      ACK 01x037j4
>
> To immediately escalate, reply to this message with this subject line:
>      NACK 01x037j4



--
Jane Customer
System Engineer                        e: $address
testcorp, Inc.                         v: (555) 555-1212
123 Sesame Street                      c: (555) 555-1212
New York City, NY  99999               f: (555) 555-1212
=
Now Shipping\! Active XYZ-- the newest TestCorp Assistant\!
' '"Jane R. Customer" <$address>'
SIX

$seven = <<SEVEN;
Received: from myway.com (myway.com [10.127.98.8])
    by myway.com (8.8.5/8.8.5) with SMTP id
    for rogerthat01\@alerts.nocpulse.com; Wed, 27 Nov 2002 07:27:30 -0800
Date: Wed, 27 Nov 2002 07:27:30 -0800
From: operationsnews\@myway.com
Message-Id: <200211299999.\@myway.com>
To: rogerthat01\@alerts.nocpulse.com
Subject: Re: [0173n6w1/4]
MIME-Version: 1.0
Content-Type: text/plain
2002-11-27 15:27:41
Response: ack
2002-11-27 15:27:41
Your Message:
> Fr:rogerthat01\@alerts.nocpulse.com
> Su:[0173n6w1/4]
> cknowledge, reply to this message with this subject line:
> ACK 0173n6w1
>
> To immediately escalate, reply to this messa

SEVEN

$eight = <<EIGHT;
From kja\@redhat.com Tue Dec 10 20:48:59 2002
Received: from monkey.nocpulse.com (monkey.nocpulse.com [63.121.136.45])
    by horse.nocpulse.com (8.11.6/8.11.6) with SMTP id gBAKmxZ13718
    for <rogerthat\@horse.nocpulse.com>; Tue, 10 Dec 2002 20:48:59 GMT
Received: from mx2.redhat.com (mx2.redhat.com [12.150.115.133])
    by monkey.nocpulse.com (8.11.6/8.11.4) with SMTP id gBAKmsl23549
    for <rogerthat01\@alerts.nocpulse.com>; Tue, 10 Dec 2002
20:48:54 GMT
Received: from int-mx1.corp.redhat.com (natpool.sfbay.redhat.com [172.16.26.200])
    by mx2.redhat.com (8.11.6/8.11.6) with ESMTP id gBAKjUJ09897
    for <rogerthat01\@nocpulse.com>; Tue, 10 Dec 2002 15:45:31 -0500
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com
[172.16.52.156])
    by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id gBAKmqD31699
    for <rogerthat01\@nocpulse.com>; Tue, 10 Dec 2002 15:48:52 -0500
Received: from rover (vpn50-31.rdu.redhat.com [172.16.50.31])
    by pobox.corp.redhat.com (8.11.6/8.11.6) with ESMTP id gBAKmpq23525
    for <rogerthat01\@nocpulse.com>; Tue, 10 Dec 2002 15:48:51 -0500
Subject: nak
From: Karen Jacqmin-Adams <kja\@redhat.com>
To: rogerthat01\@redhat.com
In-Reply-To: <200212102047.gBAKluW08035\@tarantula.nocpulse.com>
References: <200212102047.gBAKluW08035\@tarantula.nocpulse.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
X-Mailer: Ximian Evolution 1.0.8 (1.0.8-10)
Date: 10 Dec 2002 14:50:54 -0600
Message-Id: <1039553454.2281.7.camel\@rover.gb.nocpulse.net>
Mime-Version: 1.0

On Tue, 2002-12-10 at 14:47, NOCpulse Notification wrote:
> This is NOCpulse event notification 01hbklb0.
>
> Time:      Tue Dec 10, 20:47:51 GMT
> State:     UP
> Host:      dev-01 (192.168.15.111)
> Check:
> Message:
> Run from:  yourlife.net backup
>
> To acknowledge, reply to this message with this subject line:
>      ACK 01hbklb0
>
> To immediately escalate, reply to this message with this subject line:
>      NACK 01hbklb0


EIGHT

$nine = <<NINE;
Received: from myway.com (myway.com [10.127.98.8])
    by myway.com (8.8.5/8.8.5) with SMTP id
    for rogerthat01\@alerts.nocpulse.com; Wed, 27 Nov 2002 07:27:30 -0800
Date: Wed, 27 Nov 2002 07:27:30 -0800
From: operationsnews\@myway.com
Message-Id: <200211299999.\@myway.com>
To: rogerthat01\@alerts.nocpulse.com
Subject: Re: [0173n6w1/4]
MIME-Version: 1.0
Content-Type: text/plain
2002-11-27 15:27:41
Response: ack suspend check 20m
2002-11-27 15:27:41
Your Message:
> Fr:rogerthat01\@alerts.nocpulse.com
> Su:[0173n6w1/4]
> cknowledge, reply to this message with this subject line:
> ACK 0173n6w1
>
> To immediately escalate, reply to this messa

NINE

$ten = <<TEN;
Received: from myway.com (myway.com [10.127.98.8])
    by myway.com (8.8.5/8.8.5) with SMTP id
    for rogerthat01\@alerts.nocpulse.com; Wed, 27 Nov 2002 07:27:30 -0800
Date: Wed, 27 Nov 2002 07:27:30 -0800
From: operationsnews\@myway.com
Message-Id: <200211299999.\@myway.com>
To: rogerthat01\@alerts.nocpulse.com
Subject: ACK  METOO  HOST 7d  kja\@redhat.com
MIME-Version: 1.0
Content-Type: text/plain
2002-11-27 15:27:41
2002-11-27 15:27:41
Your Message:
> Fr:rogerthat01\@alerts.nocpulse.com
> Su:[0173n6w1/4]
> cknowledge, reply to this message with this subject line:
> ACK 0173n6w1
>
TEN

$eleven = <<ELEVEN;
Received: from myway.com (myway.com [10.127.98.8])
    by myway.com (8.8.5/8.8.5) with SMTP id
    for rogerthat01\@alerts.nocpulse.com; Wed, 27 Nov 2002 07:27:30 -0800
Date: Wed, 27 Nov 2002 07:27:30 -0800
From: operationsnews\@myway.com
Message-Id: <200211299999.\@myway.com>
To: rogerthat01\@alerts.nocpulse.com
Subject: 
MIME-Version: 1.0
Content-Type: text/plain
ack
   Redir Host
1H   nobody\@nocpulse.com
ELEVEN

$twelve = <<TWELVE;
Received: from myway.com (myway.com [10.127.98.8])
    by myway.com (8.8.5/8.8.5) with SMTP id
    for rogerthat01\@alerts.nocpulse.com; Wed, 27 Nov 2002 07:27:30 -0800
Date: Wed, 27 Nov 2002 07:27:30 -0800
From: operationsnews\@myway.com
Message-Id: <200211299999.\@myway.com>
To: rogerthat01\@alerts.nocpulse.com
Subject: ack AutoAck checK 1d
MIME-Version: 1.0
Content-Type: text/plain
TWELVE

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new();
                           
  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
        
}

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

  mkdir ($directory,0777);
  foreach (@files) {
    local * FILE;
    open(FILE, '>>', "$directory/$_");
    print FILE $$_;
    close(FILE);
    $self->{$_}=$MODULE->from_file("$directory/$_");
  }
  

}

###############
sub tear_down {
###############
  my $self = shift;
  # Run after each test

  `rm -rf $directory`;
}

# INSERT INTERESTING TESTS HERE

sub test_is_bounce {
  # See test_from_file_X
}

sub test_operation {
  # See test_from_file_X
}

sub test_send_id {
  # See test_from_file_X
}

sub test_server_id {
  # See test_from_file_X
}

sub test_bounce_addressee {
  # See test_from_file_X
}

####################
sub test_from_file {
####################
  my $self = shift;
  my $ack = $self->{'one'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack");

  $self->assert($ack->subject =~ /Undeliverable: CRITICAL: : yournamehere.org at 07:24 GMT/,'subject 1');
  $self->assert($ack->from =~ /postmaster\@TestOrg.com/,'from 1');
  $self->assert($ack->date =~ /21 Jul 2002 07:10:15/,   'date 1');
  $self->assert($ack->body =~ /Check:\s+yournamehere/,  'body 1');
  $self->assert($ack->is_bounce == 1,'bounce');
  $self->assert($ack->bounce_addressee =~ /postmaster/, 'bounce_addressee');
}

######################
sub test_from_file_2 {
######################
  my $self = shift;
  my $ack = $self->{'two'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack");

  $ack = $MODULE->from_file("$directory/two");
  $self->assert($ack->subject =~ /Subject: Returned mail: see transcript for details/,'subject 2');
  $self->assert($ack->from =~ /MAILER-DAEMON\@tarantula.nocpulse.com/,'from 2');
  $self->assert($ack->date =~ /19 Jul 2002 07:35:18 GMT/ , 'date 2');
  $self->assert($ack->body =~ /Run from:\s+Testorg-NOC1A/ ,'body 2');
  $self->assert($ack->is_bounce == 1,        'bounce 2');
  $self->assert($ack->operation eq 'nak',    'operation 2');
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq 'xh0rm5' ,"sendid 2 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 2');
}
 
######################
sub test_from_file_3 {
######################
  my $self = shift;
  my $ack = $self->{'three'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack");

  $self->assert($ack->subject =~ /Returned mail: Unable to deliver.  The message was not sent/,'subject 3');
  $self->assert($ack->from =~ /MAILER-DAEMON\@marsemail02.yourorg.com/,'from 3');
  $self->assert($ack->date =~ /23 Jul 2002 05:42:42 GMT/ ,'date 3');
  $self->assert($ack->body =~ /Message:Install Cluster problem: 500/ ,'body 3');
  $self->assert($ack->is_bounce == 1,        'bounce 3');
  $self->assert($ack->operation eq 'nak',    'operation 3');
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq 'lk0tl8', "sendid 3 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 3');
}
#
######################
sub test_from_file_4 {
######################
  my $self = shift;
  my $ack = $self->{'four'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack");

  $self->assert($ack->subject =~ /Returned mail: Service unavailable/,'subject 4');
  $self->assert($ack->from =~ /MAILER-DAEMON\@uunet.uu.net/,'from 4');
  $self->assert($ack->date =~ /24 Jul 2002 00:14:27 GMT/ ,'date 4');
  $self->assert($ack->body =~ /NACK 013488/ ,'body 4');
  $self->assert($ack->is_bounce == 1,        'bounce 4');
  $self->assert($ack->operation eq 'nak',    'operation 4');
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq 'xt68px', "sendid 4 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 4');
}

######################
sub test_from_file_5 {
######################
  my $self = shift;
  my $ack = $self->{'five'};
  
  $self->assert($ack->from =~ /$address/,    'from 5');
  $self->assert($ack->is_bounce == 0,        'bounce 5');
  $self->assert($ack->operation eq 'ack',    'operation 5');
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq 'gk1ncf', "sendid 5 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 5');
}

######################
sub test_from_file_6 {
######################
  my $self = shift;
  my $ack = $self->{'six'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack)");

  $self->assert($ack->from =~ /$address/,'from 6');
  $self->assert($ack->is_bounce == 0,        'bounce 6');
  $self->assert($ack->operation eq 'nak',    'operation 6');
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq 'x037j4', "sendid 6 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 6');
}
 
######################
sub test_from_file_7 {
######################
  my $self = shift;
  my $ack = $self->{'seven'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack");

  $self->assert($ack->from =~ /$address/,    'from 7');
  $self->assert($ack->is_bounce == 0,        'bounce 7');
  my $op=$ack->operation;
  $self->assert($ack->operation eq 'ack',    "operation 7 ($op)");
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq '73n6w1', "sendid 7 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 7');
}
 
######################
sub test_from_file_8 {
######################
  my $self = shift;
  my $ack = $self->{'eight'};
#    $self->assert(defined($ack), "Couldn't create $MODULE object: $@");
#    $self->assert(qr/$MODULE/, "$ack");

  $self->assert($ack->from =~ /$address/,    'from 8');
  $self->assert($ack->is_bounce == 0,        'bounce 8');
  my $op=$ack->operation;
  $self->assert($ack->operation eq 'nak',    "operation 8 ($op)");
  my $id=$ack->send_id;
  $self->assert($ack->send_id   eq 'hbklb0', "sendid 8 ($id)");
  $self->assert($ack->server_id == 1,        'serverid 8');
}

sub test_duration {
  # See test_redirect_parse_X
}

sub test_is_redirect {
  # See test_redirect_parse_X
}

sub test_redirect_type {
  # See test_redirect_parse_X
}

sub test_not_valid_redirect {
  # See test_redirect_parse_X
}

sub test_destination {
  # See test_redirect_parse_X
}

sub test_redirect_scope {
  # See test_redirect_parse_X
}

###########################
sub test_redirect_parse_1 {
###########################
  my $self = shift;
  my $ack = $self->{'nine'};
  $self->assert($ack->is_redirect,                  'is_redirect');
  $self->assert($ack->duration       =~ /^20m$/,    'duration');
  $self->assert($ack->redirect_type  =~ /^suspend$/,'redirect_type');
  $self->assert($ack->redirect_scope =~ /^check$/,  'redirect_scope');
  my $invalid=$ack->not_valid_redirect;
  $self->assert(!$invalid,"not_valid_redirect ($invalid)");
}

###########################
sub test_redirect_parse_2 {
###########################
  my $self = shift;
  my $ack = $self->{'ten'};
  $self->assert($ack->is_redirect,                  'is_redirect');
  $self->assert($ack->duration       =~ /^7d$/,     'duration');
  $self->assert($ack->redirect_type  =~ /^metoo$/,  'redirect_type');
  $self->assert($ack->redirect_scope =~ /^host$/,   'redirect_scope');
  my $dest=$ack->destination;
  $self->assert($dest eq "kja\@redhat.com", "destination [$dest]");
  my $invalid=$ack->not_valid_redirect;
  $self->assert(!$invalid,"not_valid_redirect ($invalid)");
}

###########################
sub test_redirect_parse_3 {
###########################
  my $self = shift;
  my $ack = $self->{'eleven'};
  $self->assert($ack->is_redirect,                        'is_redirect');
  $self->assert($ack->duration       =~ /^1h$/,           'duration');
  $self->assert($ack->redirect_type  =~ /^redir$/,        'redirect_type');
  $self->assert($ack->redirect_scope =~ /^host$/,         'redirect_scope');
  my $dest=$ack->destination;
  $self->assert($dest eq "nobody\@nocpulse.com", "destination [$dest]");
  my $invalid=$ack->not_valid_redirect;
  $self->assert(!$invalid,"not_valid_redirect ($invalid)");
}

###########################
sub test_redirect_parse_4 {
###########################
  my $self = shift;
  my $ack = $self->{'twelve'};
  $self->assert($ack->is_redirect,                    'is_redirect');
  $self->assert($ack->duration       =~ /^1d$/,       'duration');
  $self->assert($ack->redirect_type  =~ /^autoack$/,  'redirect_type');
  $self->assert($ack->redirect_scope =~ /^check$/,    'redirect_scope');
  my $invalid=$ack->not_valid_redirect;
  $self->assert(!$invalid,"not_valid_redirect ($invalid)");
}

##############################
sub test_duration_in_seconds {
##############################
  my $self=shift;
  my $ack=$MODULE->new();

  $ack->duration('30m');
  $self->assert($ack->duration_in_seconds() == 30 * 60,'30m');
  $ack->duration('3h');
  $self->assert($ack->duration_in_seconds() == 3 * 60 * 60,'3h');
  $ack->duration('4d');
  $self->assert($ack->duration_in_seconds() == 4 * 60 * 60 * 24,'4d');
  $ack->duration('8d');
  $self->assert($ack->duration_in_seconds() == 7 * 60 * 60 * 24,'8d');
}

##############
sub test_log {
##############
  my $self = shift;
  my $ack = $self->{'twelve'};

  my $log = test::TestAcknowledgement::Log->new;
  $ack->log($log);

  my $string=$log->_log;

  foreach (qw (from subject date body server_id
               send_id operation bounce_addressee)) {
    my $item=$ack->$_;
    $self->assert($log =~ /$item/, "$_ ($item)");
  }
}

################
sub test_reply {
################
  print STDERR "test_reply needs manual testing\n";
}

####################
sub test_as_string {
####################
  my $self=shift;
  my $ack=$MODULE->new ( _contents => 'BLAH');
  my $string=$ack->as_string;
  $self->assert($string eq 'BLAH', "test_as_string");
}



package test::TestAcknowledgement::Log;

use Class::MethodMaker
  new_hash_init => 'new',
  get_set => '_log';

sub log { 
  my $self=shift;
  my @stuff=@_;

  $self->_log(join('',$self->_log,@stuff)); 
}

1;

