#!/usr/local/bin/perl -w

use Date::Parse;
use Date::Format qw(time2str);

$data = qq!1995-01-24
1995-01-24T09:08:17.1823213
Wed, 16 Jun 94 07:29:35 CST 
Wed, 16 Nov 94 07:29:35 CST 
Mon, 21 Nov 94 07:42:23 CST 
Mon, 21 Nov 94 04:28:18 CST 
Tue, 15 Nov 94 09:15:10 GMT 
Wed, 16 Nov 94 09:39:49 GMT 
Wed, 16 Nov 94 09:23:17 GMT 
Wed, 16 Nov 94 12:39:49 GMT 
Wed, 16 Nov 94 14:03:06 GMT 
Wed, 16 Nov 94 05:30:51 CST 
Thu, 17 Nov 94 03:19:30 CST 
Mon, 21 Nov 94 14:05:32 GMT 
Mon, 14 Nov 94 15:08:49 CST 
Wed, 16 Nov 94 14:48:06 GMT 
Thu, 17 Nov 94 14:22:03 GMT 
Wed, 16 Nov 94 14:36:00 GMT 
Wed, 16 Nov 94 09:23:17 GMT 
Wed, 16 Nov 94 10:01:43 GMT 
Wed, 16 Nov 94 15:03:35 GMT 
Mon, 21 Nov 94 13:55:19 GMT 
Wed, 16 Nov 94 08:46:11 CST 
21 dec 17:05
21-dec 17:05
21/dec 17:05
21/dec/93 17:05
dec 21 1994 17:05
dec 21 94 17:05
dec 21 94 17:05 GMT
dec 21 94 17:05 BST
dec 21 94 00:05 -1700
dec 21 94 17:05 -1700
Wed, 9 Nov 1994 09:50:32 -0500 (EST) 
Thu, 13 Oct 94 10:13:13 -0700
Sat, 19 Nov 1994 16:59:14 +0100 
Thu, 3 Nov 94 14:10:47 EST 
Thu, 3 Nov 94 21:51:09 EST 
Fri, 4 Nov 94 9:24:52 EST 
Wed, 9 Nov 94 09:38:54 EST 
Mon, 14 Nov 94 13:20:12 EST 
Wed, 16 Nov 94 17:09:13 EST 
Tue, 15 Nov 94 12:27:01 PST 
Fri, 18 Nov 1994 07:34:05 -0600 
Mon, 21 Nov 94 14:34:28 -0500 
Fri, 18 Nov 1994 12:05:47 -0800 (PST) 
Fri, 18 Nov 1994 12:36:26 -0800 (PST) 
Wed, 16 Nov 1994 15:58:58 GMT 
1999 10:02:18 "GMT"
Sun, 06 Nov 94 14:27:40 -0500 
Mon, 07 Nov 94 08:20:13 -0500 
Mon, 07 Nov 94 16:48:42 -0500 
Wed, 09 Nov 94 15:46:16 -0500 
Fri, 4 Nov 94 16:17:40 "PST 
Wed, 16 Nov 94 12:43:37 "PST 
Sun, 6 Nov 1994 02:38:17 -0800 
Tue, 1 Nov 1994 13:53:49 -0500 
Tue, 15 Nov 94 08:31:59 +0100 
Sun, 6 Nov 1994 11:09:12 -0500 (IST) 
Fri, 4 Nov 94 12:52:10 EST 
Mon, 31 Oct 1994 14:17:39 -0500 (EST) 
Mon, 14 Nov 94 11:25:00 CST 
Mon, 14 Nov 94 13:26:29 CST 
Fri, 18 Nov 94 8:42:47 CST 
Thu, 17 Nov 94 14:32:01 +0900 
Wed, 2 Nov 94 18:16:31 +0100 
Fri, 18 Nov 94 10:46:26 +0100 
Tue, 8 Nov 1994 22:39:28 +0200 
Wed, 16 Nov 1994 10:01:08 -0500 (EST) 
Wed, 2 Nov 1994 16:59:42 -0800 
Wed, 9 Nov 94 10:00:23 PST 
Fri, 18 Nov 94 17:01:43 PST 
Mon, 14 Nov 1994 14:47:46 -0500 
Mon, 21 Nov 1994 04:56:04 -0500 (EST) 
Mon, 21 Nov 1994 11:50:12 -0800 
Sat, 5 Nov 1994 14:04:16 -0600 (CST) 
Sat, 05 Nov 94 13:10:13 MST 
Wed, 02 Nov 94 10:47:48 -0800 
Wed, 02 Nov 94 13:19:15 -0800 
Thu, 03 Nov 94 15:27:07 -0800 
Fri, 04 Nov 94 09:12:12 -0800 
Wed, 9 Nov 1994 10:13:03 +0000 (GMT) 
Wed, 9 Nov 1994 15:28:37 +0000 (GMT) 
Wed, 2 Nov 1994 17:37:41 +0100 (MET) 
05 Nov 94 14:22:19 PST 
16 Nov 94 22:28:20 PST 
Tue, 1 Nov 1994 19:51:15 -0800 
Wed, 2 Nov 94 12:21:23 GMT 
Fri, 18 Nov 94 18:07:03 GMT 
Wed, 16 Nov 1994 11:26:27 -0500 
Sun, 6 Nov 1994 13:48:49 -0500 
Tue, 8 Nov 1994 13:19:37 -0800 
Fri, 18 Nov 1994 11:01:12 -0800 
Mon, 21 Nov 1994 00:47:58 -0500 
Mon, 7 Nov 1994 14:22:48 -0800 (PST) 
Wed, 16 Nov 1994 15:56:45 -0800 (PST) 
Thu, 3 Nov 1994 13:17:47 +0000 
Wed, 9 Nov 1994 17:32:50 -0500 (EST)
Wed, 9 Nov 94 16:31:52 PST
Wed, 09 Nov 94 10:41:10 -0800
Wed, 9 Nov 94 08:42:22 MST
Mon, 14 Nov 1994 08:32:13 -0800
Mon, 14 Nov 1994 11:34:32 -0500 (EST)
Mon, 14 Nov 94 16:48:09 GMT
Tue, 15 Nov 1994 10:27:33 +0000 
Wed, 02 Nov 94 13:56:54 MST 
Thu, 03 Nov 94 15:24:45 MST 
Thu, 3 Nov 1994 15:13:53 -0700 (MST)
Fri, 04 Nov 94 08:15:13 MST 
Thu, 3 Nov 94 18:15:47 EST
Tue, 08 Nov 94 07:02:33 MST 
Thu, 3 Nov 94 18:15:47 EST
Tue, 15 Nov 94 07:26:05 MST 
Wed, 2 Nov 1994 00:00:55 -0600 (CST) 
Sun, 6 Nov 1994 01:19:13 -0600 (CST) 
Mon, 7 Nov 1994 23:16:57 -0600 (CST) 
Tue, 08 Nov 1994 13:21:21 -0600 
Mon, 07 Nov 94 13:47:37 PST 
Tue, 08 Nov 94 11:23:19 PST 
Tue, 01 Nov 1994 11:28:25 -0800 
Tue, 15 Nov 1994 13:11:47 -0800 
Tue, 15 Nov 1994 13:18:38 -0800 
Tue, 15 Nov 1994 0:18:38 -0800 
!;

@data = split(/\n/, $data);

print "1..", scalar(@data),"\n";
$loop = 1;

foreach (@data)
{
 $time = str2time($_);

 if(defined $time)
  {
   $x = time2str("%a %b %e %T %Y %Z",$time,'GMT');

   printf "%-40s\t%s\n", $_,$x,"\n";

   $y = str2time($x);

   print "",($y == $time) ? "ok $loop\n" : "not ok $loop # $y != $time\n";
  }
 else
  {
   print "not ok $loop # $_\n";
  }

 $loop++;
}

