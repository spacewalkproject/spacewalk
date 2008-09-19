--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
-- $Id$
--
-- EXCLUDE: production

-- data for rhnFAQ in the satellite case

SET SQLBLANKLINES ON
SET SCAN OFF

INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
64, 'pvt: This message is being forwarded to customerservice@redhat.com', 'This message has been forwarded to customerservice@redhat.com.  That group handles all billing and purchasing related questions.'
, 1,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/12/2003 10:18:24 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 22, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
65, 'I''m having trouble registering my Red Hat Enterprise Linux product.  Why?', 'Enterprise entitlements are required for use with Red Hat Enterprise Linux.

A customer who registers an Enterprise Linux system with Spacewalk without having any Enterprise Linux entitlements will receive an error message similar to:

"No public channels available for ("2.1AS'', ''i686'')"

In order to register your system, you first need to activate your Spacewalk Enterprise Linux entitlements at:

http://www.redhat.com/support

Use the product ID that came with your Red Hat Enterprise Linux product.
'
, 0,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:12 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 13, 7); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
66, 'pvt: I bought service with Spacewalk, but it won''t let me use Priority FTP access.  Why not?vp'
, 'Instant ISO access is not the same as Priority FTP access; they are separate entities.  Customers who purchase Spacewalk service have Instant ISO access only.  Priority FTP access is available only to legacy users, and is in the process of being phased out.
'
, 1,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/24/2003 09:34:56 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 6, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
67, 'How do I register a system for Spacewalk service on Red Hat Linux?', 'To register a system for Spacewalk service on Red Hat Linux please run "rhn_register". Refer to the Spacewalk User Guide (also available through the Help link at the Spacewalk website) for additional instructions.

Note: for Red Hat Linux 8.0 and later, please run "up2date --register" instead of "rhn_register".
'
, 0,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/16/2003 09:09:30 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 19, 3); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
25, 'The Spacewalk website and up2date do not agree on what errata is needed for my system.'
, 'You can refresh the profile package list by running "up2date -p" on the machine itself.  Alternatively, you can schedule this from the website by clicking on the system in the System List, choosing the Packages tab, and then clicking on the "Update Package List" button at the bottom of the page.
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/14/2003 09:24:01 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 10, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
26, 'I had to re-install my system. How do I re-register and get my entitlement back?'
, 'You''ll need to re-register the client system if you haven''t already, and then move an entitlement to the new profile.

* Log into our website at:  https://rhn.redhat.com.
* Click on "Systems" in the top navigation bar, then the name of the old system in the System List.
* Click "delete system" on the top-right corner of the page.
* As root at the command line, delete the file /etc/sysconfig/rhn/systemid from your system.
* Run "rhn_register" (Red Hat Linux 7.x) or "up2date --register" (Red Hat Linux 8.0 and newer) on your system.
* Once the system is registered, log in at https://rhn.redhat.com.
* Click "Systems" in the top navigation bar, then "System Entitlements" on the left.
* Select the appropriate entitlement level for the new system and click "Update Entitlements."'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/18/2003 09:42:55 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 411, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
27, 'How can I request a new feature or improvement for the Spacewalk?', 'For technical requests, you can make a "Request for Enhancement" (RFE) at http://bugzilla.redhat.com/bugzilla.  The product is "Spacewalk" and the various components are prefaced by "Spacewalk/".  Please put "[RFE]" at the beginning of the summary line of your request.

If you would like to provide non-technical feedback to Spacewalk, please go to https://rhn.redhat.com/help/contact.pxt and follow the directions for "feedback".
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/18/2003 09:56:14 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 74, 9); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
28, 'Where do I report a bug in the Spacewalk website or update agent?', 'Bugs can be reported at http://bugzilla.redhat.com/bugzilla -- the product is "Spacewalk", and the various components are prefixed with "Spacewalk/".

Please be sure to read the FAQ and review all of the open bugs before submitting your bug.
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/15/2003 10:47:49 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 45, 9); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
30, 'What is the difference between i386, i586, and i686 packages?', 'i386 is a generic designation for all processors backwardly compatible with the Intel 80386; i586 is for all processors backwardly compatible with the Intel Pentium; and i686 is for Intel processors backwardly compatible with the Pentium Pro chip (Pentium II, III, IV, etc).  Only the kernel has i586 and i686 versions, and glibc has an i686 version.  up2date should automatically determine which versions of the kernel and glibc packages are appropriate for your systems.
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/15/2003 10:33:49 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 8, 11); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
1, 'What is Spacewalk?', 'Spacewalk is a systems support and management environment for Red Hat Linux systems and networks. For more information, please see the Spacewalk product information page:
http://www.redhat.com/software/rhn/products/

For individual systems and small networks, see http://www.redhat.com/software/rhn

For enterprise deployments, see http://www.redhat.com/software/rhen
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/14/2003 05:00:08 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 26, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
3, 'Does Spacewalk only work on Linux? Which versions?', 'Yes. Spacewalk currently only supports versions of Red Hat Linux and Red Hat Enterprise Linux that are still active (have not yet reached End of Life status). For a list of currently maintained Red Hat versions, please go to http://www.redhat.com/apps/support/errata/

Please note that Red Hat''s Enterprise Network Monitoring Module does support different platforms. For more information, please go to http://www.redhat.com/software/rhen/system_mgmt/
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:12 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 4, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
5, 'I can''t find the Spacewalk Registration Client.  What is it and where do I find it?'
, 'The Spacewalk Registration Client steps you through the process of creating a user account if you do not already have one and registering your system by creating a System Profile. It can be started by using one of the following methods:

* On the GNOME desktop, go to the Main Menu Button (on the Panel) => Programs => System => Spacewalk.
* On the KDE desktop, go to the Main Menu Button (on the Panel) => System => Spacewalk
* At a shell prompt, type the command "rhn_register".

In Red Hat Linux 8.0 and newer, rhn_register exists as a mode of the up2date client, so:

* On the GNOME and KDE desktops, go to the Main Menu Button (on the Panel) => System Tools => Spacewalk. (If the system is unregistered, it will automatically launch in registration mode.)
* At a shell prompt (for example, an xterm or gnome-terminal), type the command "up2date --register".
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/19/2003 01:31:52 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 126, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
7, 'I forgot my username and password. How do I access my account?', 'From the front page, click on the "Lost Password?" link, enter your username and email address, and then click the "Send Password" button.

If you have neither your username nor your password, enter your email address in the second field provided, and then click the "Send Account List" button.

If the email address matches the email address on file for your account, your information will be sent to you. If this does not work for you, please call our customer service desk at 1-866-2-RedHat.
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/16/2003 09:14:22 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 16, 2); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
8, 'What are the service levels for Spacewalk?', 'Spacewalk currently offers three levels of service: Spacewalk Demo Service, Spacewalk Update Service and Spacewalk Management Service.  For more details, go to http://www.redhat.com/software/rhn/offerings
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/08/2003 03:43:45 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 50, 4); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
69, 'pvt: You are sending packets to my machine! (Firewall log attached)', 'As you can see, the packets you are seeing are response packets coming from our host and port 443 to your machine.

These packets have the SYN/ACK flags set up. These types of packets are sent only in response to a connection request from your computer.

TCP uses a three-way handshake protocol to establish a connection:
* the client sends a SYN packet to the server requesting a connection
* the server acknowledges the request and sends back a SYN/ACK packet
* the client responds back with an ACK packet and the connection is established

Your firewall rules are not allowing the server responses to pass through.  The rhnsd daemon is initiating these requests. You have 2 choices:

* fix the firewall rules so you allow the reply packets to pass through and therefore allow your host to connect outside; or
* disable the rhnsd daemon: service rhnsd stop
'
, 1,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 3, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
125, 'pvt: no RHL support at rhn-help', 'This address is intended for support questions related only to Red Hat
Network. General Red Hat Linux support is not available from this address.

If you have not already done so, you can activate your product and receive advanced support at:

https://www.redhat.com/apps/support/

Even if you are not registered with Red Hat Support, you are welcome to browse
our documentation and online resources available at:

https://www.redhat.com/docs/

You may also get access to Tips, FAQs, and online HOWTOs to guide you through
Linux-related tasks if you start looking from our Support Resources Home Page
available at:

https://www.redhat.com/apps/support/resources/

The Red Hat mailing lists are also good venues for finding answers to your
questions. For more information on the Red Hat mailing lists, please see:

http://www.redhat.com/mailing-lists/

If you would like to report a bug or a problem with a component of the Red Hat Linux distribution, we encourage you to visit our bug tracking system and file a bug report at:

http://bugzilla.redhat.com/bugzilla
'
, 1,  TO_Date( '12/11/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:12 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 288, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
126, 'How do I change my Spacewalk password?', 'To change your password:

* Log in to the Spacewalk website with your existing username and password.
* If you are not at Your Spacewalk page, click its link in the top navigation bar.
* Click "Your Account" in the left navigation bar.
* Type your new password in both the Password and Password Confirmation fields.
* Click the "Update" button.
'
, 0,  TO_Date( '12/12/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:12 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 9, 2); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
13, 'What is "rhnsd" and why is it running on my system?', '"rhnsd" is the Spacewalk Daemon. Every other hour, it sends a request to Spacewalk asking for any notifications or updates and works in coordination with Spacewalk to schedule automated tasks. It sends information to Spacewalk only requested by you. If you add a new system using the Spacewalk web interface, the next time the Spacewalk Daemon probes Spacewalk it receives a request to return the information you requested as part of your System Profile, such as what package versions are installed on your system.
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/08/2003 10:52:29 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 9, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
15, 'My systems are not checking in.  What does that mean?', 'When the Spacewalk client connects to Spacewalk to see if there are any updates available, or if any actions have been scheduled, this is considered a checkin.

If you are seeing a message indicating that checkins are not happening, it means that the Spacewalk client on your system is not successfully reaching Spacewalk for some reason. Things to check:
* Make certain that your client is configured correctly.
* Make sure that your system can communicate with Spacewalk via SSL (port 443).  You may test this by running the following command from a shell prompt: telnet xmlrpc.rhn.redhat.com 443
* Make sure that the rhnsd daemon is activated and running.  You may ensure this by running the following commands:
chkconfig --level 345 rhnsd on
service rhnsd start

If these settings are correct and your system still is not checking in, the ''Repairing a corrupt rpm database'' faq at http://rhn.redhat.com/help/faq/technical_questions.pxt#227 , or get in touch with our technical support team.
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/14/2003 05:04:29 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 151, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
17, 'Can I use Spacewalk to upgrade my Red Hat Linux kernel?', 'Yes. You must use Red Hat Update Agent version 2.5.4 or higher. If you choose the kernel packages and allow Spacewalk to install them to your system, it will modify your LILO or GRUB configuration file so that your system boots the new kernel the next time it is rebooted.
'
, 0,  TO_Date( '03/07/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:12 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 11, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
41, 'pvt: Updates to newer versions recommended by third-party security advisories.'
, 'We have released fixes for all known vulnerabilities you are mentioning.  Red Hat does not usually update to a new code base for the core applications and libraries if we have other options available. In the cases you have mentioned we choose to backport the security fixes to the code base we initially shipped to our customers. We do this in order to minimize the impact on the stability and the QA resources that both we and the customers invest in qualifying a particular release for a particular task.

The latest versions of those packages provided by Red Hat are not vulnerable to the issues you mention.
'
, 1,  TO_Date( '10/01/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/13/2003 11:31:22 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 10, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
62, 'Is Red Hat Technical Support available in other languages besides English?', 'At this time, Spacewalk technical support is English only.
'
, 0,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/27/2003 10:32:41 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 26, 4); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
63, 'How do I download RPMs for a system without using up2date?', 'It is possible for Spacewalk users to download updated packages directly from the Spacewalk website without using up2date.

To download them:

* Log in to the Spacewalk web site.
* Click "Software" in the top navigation bar.
* Click the appropriate channel name.
* On the Channel Details page, click the "Packages" tab.
* Select the RPMs you want and click the "Download" button. You will be presented with a confirmation screen.
* Click "Download Selected Packages Now!"
* You will then be asked for the location to save the tar archive containing all the packages you selected.
* To extract the packages once the download is complete, run: tar -xvf rhn-packages.tar
'
, 0,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:12 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 9, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
31, 'The update agent wants to install an older version of a package.  Why?', 'This is probably because of the epoch number of the package.  RPM checks three things when it tries to determine whether a package is newer: epoch, version, and release, in that order.  A higher epoch number trumps both version and release.  To see the epoch number on an installed package, use the command:

rpm -q --queryformat "%{NAME}-%{VERSION}-%{RELEASE}:%{EPOCH}\n" packagename

The epoch is the number after the colon.  On the Spacewalk website, you can also see the epoch for the package on the Installed Packages list for the system, (again, the number after the colon).

Epoch numbers are used to preserve RPM''s concept of "newer" when package versions are changed inconveniently. The classic example of the need for an epoch is perl, which changed from version 5.00503 to 5.6, thereby breaking rpm''s segmented version comparison (i.e the integer 6 < 503, rather than 5.6 > 5.00503).

To keep the update agent from trying to update your package, add it to the package skip list (pkgSkipList) in your up2date configuration:

up2date --configure --nox

However, the package will still show up on your list of applicable errata.
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/06/2003 10:26:15 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 7, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
32, 'pvt: Red Hat Linux support', 'This address is intended for support questions related only to Spacewalk. General Red Hat Linux support is not available from this address.  If you are registered with Red Hat Support, you may address your questions at:
http://www.redhat.com/support

If you have not already done so, you can activate your product and receive advanced support at:

https://www.redhat.com/apps/support/

Even if you are not registered with Red Hat Support, you are welcome to browse
our documentation and online resources available at:

https://www.redhat.com/docs/

You may also get access to Tips, FAQs, and online HOWTOs to guide you through
Linux-related tasks if you start looking from our Support Resources Home Page
available at:

https://www.redhat.com/apps/support/resources/

The Red Hat mailing lists are also good venues for finding answers to your
questions. For more information on the Red Hat mailing lists, please see:

http://www.redhat.com/mailing-lists/

If you would like to report a bug or a problem with a component of the Red Hat Linux distribution, we encourage you to visit our bug tracking system and file a bug report at:

http://bugzilla.redhat.com/bugzilla
'
, 1,  TO_Date( '06/22/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/19/2003 01:13:04 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 768, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
33, 'How do I delete System Profiles?', 'In order to delete System Profiles from Spacewalk, you need to log in to the Spacewalk website at https://rhn.redhat.com.  Once logged in, click on the "Systems" link in the top navigation bar, which will take you to a list of the profiles you have registered with Spacewalk. (If you instead see System Groups, click "View Systems" near the top of the page.)

Click on the name of the profile you wish to delete from the service. This will bring up its System Details page. Click the "delete system" button at the top-right corner of the page. Then confirm that you wish to delete the profile.

The profile will be removed after confirmation.
'
, 0,  TO_Date( '06/24/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/12/2003 10:57:15 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 89, 7); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
36, 'pvt: Educational Channel', 'The educational channel and Red Hat educational initiative is currently undergoing some changes (all for the positive). Please stay tuned and periodically check the following websites for more information:

www.redhat.com
www.redhat.com/index2.html
www.redhat.com/software/rhn
'
, 1,  TO_Date( '08/20/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:13 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 14, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
35, 'An errata install fails with dependency errors, but dependencies are satisfied.  Why?'
, 'Sometimes the application of an errata from the Spacewalk web site will fail because the errata applies to packages that are set to be skipped in the local skip list for a system''s up2date client.  The error message in the history log will incorrectly cite a dependency problem.

To fix this problem, run:

up2date --configure

...as root from the client system, and remove the relevant packages from the skip list.  Rescheduling the errata should then work as expected.
'
, 0,  TO_Date( '08/20/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/13/2003 10:24:11 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 23, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
249, 'Where can I see a copy of the SLA (Service Level Agreement) for Spacewalk Technical Support?'
, 'This can be viewed online at the following site:

http://www.redhat.com/services/techsupport/production/RHN_basic.html'
, 0,  TO_Date( '03/31/2003 11:55:25 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/09/2003 11:00:32 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 6, 4); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
288, 'My system''s IP address and hostname have changed, but Spacewalk doesn''t reflect this. What should I do?'
, 'Spacewalk stores a profile for each registered system. In addition to properties set by the user during registration, this profile may contain various kinds of information about the system''s hardware, including processor type, networking addresses, and storage devices. This information can be found in the Spacewalk website:

1. Once logged in, click on Systems in the top navigation bar.
2. Click on the name of a system in one of the lists. (This may require leaving a System Groups view.)
3. In the System Details page, click the Hardware subtab. All of the hardware information Spacewalk has collected about your system will appear on the resulting page.
4. To update this information, click the Schedule Hardware Refresh button. The hardware profile will be updated at the system''s next connection to Spacewalk.'
, 0,  TO_Date( '04/22/2003 04:00:05 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/23/2003 09:45:57 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
290, 'Why does up2date tell me "Your system is fully updated" when the Spacewalk website lists updates for my system?'
, 'This error is likely caused by one of two problems: Either the system''s package profile on Spacewalk is out of date or up2date''s package exceptions list is preventing the updates from occurring.

Since updating the package profile is simplest, try this first. Log into the Spacewalk website, click "Systems" in the top navigation bar, and then click the name of the system. In the System Details page, click the "Packages" tab and then click the "Update Package List" button. The profile will be updated when the system next connects to Spacewalk. This should either remove the updates listed for your system or allow you to conduct the updates if they remain.

If this still does not resolve the error, check your package exceptions list, which enables you to identify packages to be exempt from updates. To ensure your settings are not preventing the updates, launch the Update Agent Configuration Tool by running the command:

up2date-config

In the tool, click the "Package Exceptions" tab and look for the packages listed as requiring updating.
To check the package skip list in the up2date configuration file, open the file /etc/sysconfig/rhn/up2date and look for the package entries under the pkgSkipList setting. To override the package exceptions and force an update of the entire system, run the command:

up2date -uf

If the packages aren''t updated, the Spacewalk website will continue to list them as outdated, regardless of their inclusion in the system''s package exceptions list.'
, 0,  TO_Date( '04/22/2003 06:32:03 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/25/2003 08:04:45 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
291, 'Why does Apache fail to restart after I update my Spacewalk Management Satellite Server?', 'Apache RPMs do not restart the httpd service upon installation. Therefore, after conducting a full update of an Spacewalk Management Satellite Server (such as with the command up2date -uf), Apache fails. The error will look something like:

[Mon Feb 10 11:50:12 2003] [notice] SIGHUP received.  Attempting to restart
Syntax error on line 214 of /etc/httpd/conf/httpd.conf: Cannot load /etc/httpd/modules/mod_log_config.so into server: /etc/httpd/modules/mod_log_config.so: undefined symbol: ap_escape_logitem

To resolve this, restart the httpd service.'
, 0,  TO_Date( '04/22/2003 08:27:51 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/23/2003 09:48:30 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 7); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
308, 'How do I resolve dropped connections during ISO downloads?', 'Red Hat recommends using the Curl open source tool for downloading ISO images. This tool enables you to resume downloads that have been interrupted. If you use Spacewalk and don''t currently have Curl, you may install it by running the command "up2date curl" from a shell prompt.

Once Curl is installed, at a shell prompt, cut and paste the URL for the ISO into the Curl command as follows:

[user@localhost home]$ curl -C - -O ''very_long_url''

The URL, which can be derived from the Easy ISOs page of the Spacewalk website, is very long because it contains session authentication information. Be sure to include the single quotation marks around it. The ''-C -'' option allows you to continue the download if it is interrupted, such as by a lost connection. The ''-O'' (the letter ''O'', not a zero) option will save the file with the same name as on the Spacewalk Servers.'
, 0,  TO_Date( '04/30/2003 07:02:36 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/02/2003 11:41:21 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
310, 'Why does the registration process prompt me for an organization ID if I don''t need one to register?'
, 'The organization ID is legacy from the days in which Spacewalk allowed users to request addition to an existing organization, which then required an Organization Administrator to approve the new user.

Now, the Spacewalk website allows Organization Administrators to create user accounts directly. Unfortunately, older versions of the registration tools (both rhn_register and up2date) still contain organization ID and password fields. You may disregard them.'
, 0,  TO_Date( '05/02/2003 08:51:09 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/03/2003 09:07:56 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 3); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
221, 'How do I get more legal information?', 'Please go to http://www.redhat.com/software/rhn/legal'
, 0,  TO_Date( '03/27/2003 06:47:21 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 8); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
224, 'What is an ISO?', 'An ISO is an image file of the contents of a CD.

For example, by downloading the Red Hat Linux ISOs to your system, you can then burn a CD that will be identical to the Red Hat Linux CDs that are available in retail stores.'
, 0,  TO_Date( '03/28/2003 11:22:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/16/2003 09:07:32 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 11); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
225, 'What is Errata?', 'An Errata is a message about new updates for your system, usually accompanied by updated packages.

Spacewalk is a tool to update your system with these errata packages.'
, 0,  TO_Date( '03/28/2003 11:25:25 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/16/2003 09:08:17 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 11); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
227, 'How do I repair a corrupt RPM database?', 'Occasionally, the RPM database on a Red Hat Linux machine will become corrupt.  This usually happens when an RPM transaction is interrupted at a critical time.  Symptoms of this problem include one of the following programs not responding or freezing:

* up2date
* The Spacewalk alert notification tool (applet in the Gnome or KDE panel)
* rhn_check
* rpm

This problem can also cause a system to stop checking in with Spacewalk.

To fix this problem, run the following commands as root:

* kill all RPM processes (rhn_check, up2date, rpm, rhn-applet):
     $ ps -axwww | grep rhn_check
In the list of processes, the first number on each line is the PID.  For all PIDs listed except for the one associated with grep:
     $ kill -9 <PID>
Repeat the above steps for each of the programs listed.

* remove any RPM lock files (/var/lib/rpm/__db*):
     $ rm -rf /var/lib/rpm/__db*

* rebuild the rpm database:
     $ rpm --rebuilddb

If the above steps do not work, please contact technical support for more assistance.'
, 0,  TO_Date( '03/28/2003 11:34:34 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/07/2003 11:31:57 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 2, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
231, 'How do I move my Spacewalk entitlement to another machine?', 'All of the systems that you want to entitle, or un-entitle, must be registered with Spacewalk. Please see the FAQ question relating to registering new systems.

First Step - unentitle old system

1) Sign in with Spacewalk
2) Click on "Systems"
3) Click on "Systems Entitlements"
4) Change entitlement of old system to "none"
5) Click "Update Entitlements"

Next Step - entitle new system

From same screen, change the entitlement on the new system to the entitlement you would like to have. Click "Update Entitlements".'
, 0,  TO_Date( '03/28/2003 12:07:10 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/14/2003 09:33:40 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 2, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
230, 'I just upgraded my system. How do I re-register it with Spacewalk?', 'If you are running a version of Red Hat Linux 7.3 (or prior release), do the following:

1) Log in as root
2) Type "rhn_register"

If you are running a version of Red Hat Linux 8.0 (or later release), do the following:

1) Log in as root
2) Type "up2date --register"'
, 0,  TO_Date( '03/28/2003 12:01:49 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/24/2003 10:47:23 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 2, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
232, 'How do I get copies of the latest release notes for Spacewalk?', 'Click on the Help button in the upper right hand corner. Then click on Release Notes listed on the navigation bar on the left.'
, 0,  TO_Date( '03/28/2003 12:16:19 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
70, 'pvt: Updating kernel and config files', 'Because of the wide range of changes and setups involved in the scenarios you describe we have chosen the conservative path in the default configuration.

We recommend that you upgrade the kernel on the boxes while you can observe the process (ie, running "up2date --force kernel" from the command line). The same goes for the packages which have config files DBmodified - please check the results of the upgrade process to make sure you will not have an interruption of service due to changed config files.

Once you have been through this process a few times and get a better feel for how Spacewalk handles your particular setup, you can decide to let Spacewalk perform these updates for you automatically.
'
, 1,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/14/2003 10:30:31 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 26, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
73, 'pvt: I can''t get into ftp.redhat.com. Why?', '
Due to the popularity of Red Hat Linux 8.0, our ftp servers are currently heavily loaded, and are at their capacity. We apologize for any inconvenience this may cause.

If you are not able to log into the ftp.redhat.com ftp site, it is probably because the servers are serving the maximum number of users currently. You can try later, or better yet, try one of the many Red Hat mirror sites. They are listed at:

https://www.redhat.com/download/mirror.html
  '
, 1,  TO_Date( '10/02/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/24/2003 09:35:36 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 3, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
82, 'Red Hat''s "GPG Key" - what is it and how do I install it?', 'The first time you run the graphical version of the Red Hat Update Agent, it prompts you to install the Red Hat GPG key. This key is required to authenticate the packages downloaded from Spacewalk. If you run the command line version the first time you start Red Hat Update Agent, you need to install the Red Hat GPG key manually; follow the instructions that up2date displays.'
, 0,  TO_Date( '10/17/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/06/2003 11:15:40 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 10, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
124, 'pvt: no RHL support at rhn-feedback', 'This address is intended for feedback related only to Red Hat
Network. General Red Hat Linux support is not available from this address.
If you are registered with Red Hat Support, you may address your questions
at:
http://www.redhat.com/support

Even if you are not registered with Red Hat Support, you are welcome to browse
our documentation and online resources available at:

https://www.redhat.com/docs/

You may also get access to Tips, FAQs, and online HOWTOs to guide you through
Linux-related tasks if you start looking from our Support Resources Home Page
available at:

https://www.redhat.com/apps/support/resources/

The Red Hat mailing lists are also good venues for finding answers to your
questions. For more information on the Red Hat mailing lists, please see:

http://www.redhat.com/mailing-lists/

If you would like to report a bug or a problem with a component of the Red Hat Linux distribution, we encourage you to visit our bug tracking system and file a bug report at:

http://bugzilla.redhat.com/bugzilla'
, 1,  TO_Date( '12/11/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 10, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
191, 'pvt: I want to unsubscribe from the maillist !', 'To stop receiving mails from Spacewalk , please see below:

Use your Spacewalk account to login, then go to "Your Spacewalk"==>"Your preferences" .

The Your Preferences page allows you to configure Spacewalk options, including:

      Errata Email Notification — Determine whether you want to receive email every time an Errata Alert is applicable to one or more systems in your Spacewalk account.

      Spacewalk List Page Size — Maximum number of items that will appear in a list on a single page. If more items are in the list, clicking the Next button will display the next group of items. This preference applies to system lists, Errata lists, package lists, and so on.

      Time Zone — Set your time zone so that scheduled actions are scheduled according to the time in your time zone.

      Red Hat Contact Options — Identify what ways (email, phone, fax, or mail) Red Hat may contact you.

After making changes to any of these options, click the Save Preferences button on the bottom right-hand corner.
'
, 1,  TO_Date( '02/19/2003 08:20:46 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/27/2003 11:53:51 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 89, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
209, 'I can''t log in with my username or password.  What should I do?', 'First, please check to see if you are using the correct username and password (see answers to questions in this section). If you are using the correct username and password, please call customer service at 1-866-2-RedHat or contact them at customerservice@redhat.com'
, 0,  TO_Date( '03/27/2003 03:57:30 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:10 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 2); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
228, 'pvt: How can I subscribe for Red Hat 9 now?', 'Red Hat Linux 9 ISOs will be available to paid subscribers starting March 31, 2003--a week before they will be available on redhat.com, in stores, or on Red Hat FTP. A paid subscription also gets you access to Spacewalk technical support, errata updates, priority access during peak times, and immediate email notification. It''s the quickest way to get Red Hat Linux 9.

Note: Spacewalk does not include printed documentation or Red Hat Linux Installation Support. If that''s what you''re looking for,  you can purchase Red Hat Linux 9 at redhat.com or at retail stores, available April 7, 2003. Red Hat Linux 9 or Red Hat Linux 9 Professional includes source code and documentation CDs, printed documentation manuals, installation support, and 1- or 2- month Update Subscription to Spacewalk.

For more informations please visit this page:
http://www.redhat.com/mktg/rh9iso/
'
, 1,  TO_Date( '03/25/2003 03:09:59 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/06/2003 09:07:11 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 9, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
208, 'I am new to Spacewalk. How do I create an account?', 'Go to http://rhn.redhat.com and click on the link that says "Create Account". From here, please follow the directions.'
, 0,  TO_Date( '03/27/2003 03:55:40 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 3); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
210, 'How do I login to Spacewalk?', 'Go to http://rhn.redhat.com

From this page, enter in your username and password in the box. If you do not have your username and password, please see the FAQ relating to this.'
, 0,  TO_Date( '03/27/2003 03:59:43 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 3); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
212, 'How do I contact Spacewalk?', 'To contact Spacewalk, please go to: http://www.redhat.com/software/rhn/contact'
, 0,  TO_Date( '03/27/2003 04:02:07 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
215, 'How do I know when I need to update my system?', 'Once your system is registered on Spacewalk, a small icon will appear on your tool bar (Red Hat Linux 7.3 and higher). The icon will display either an exclamation point with red background (meaning that there is an update waiting to be downloaded) or a check mark with blue background (meaning that there are no updates waiting). If your icon portrays a question mark, it means that Spacewalk is not able to see your system.

By double clicking on the icon, this will activate Spacewalk update tool.'
, 0,  TO_Date( '03/27/2003 04:27:48 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
217, 'Can I use Spacewalk to upgrade to a newer version of Red Hat Linux?', 'No. While Spacewalk always supports the latest version of Red Hat Linux, Spacewalk cannot be used today to upgrade your system from one version of Red Hat Linux to the next. You will need to do a CD based install. However, if you are a paid subscriber to Spacewalk (Update or Management), you have access to the new Red Hat Linux ISOs the moment they are made available. For more information, see http://www.redhat.com/software/rhn/offerings
'
, 0,  TO_Date( '03/27/2003 04:39:01 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 5); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
219, 'What are the terms and conditions of Spacewalk?', 'To see a copy of the Spacewalk Terms and Conditions, please go to http://www.redhat.com/licenses/rhn.html'
, 0,  TO_Date( '03/27/2003 06:03:20 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:11 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 0, 8); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
23, 'How do I remove a pending action?', 'A pending action will be removed when there are no longer any systems scheduled for it.  For Demo or Update entitlements this will always be done on a per system basis:

* Log into the Spacewalk website.
* Click "Schedule" on the top navigation bar, then "Pending Actions" in the left navigation bar.
* Click on the numeral in the "In Progress" column of the row for the action you want to remove.
* Click on the desired system name.
* Click on the "Events" tab in the System Details navigation.
* Click on the "Pending" subtab.
* Select the event you wish to cancel, and click "Cancel Events"
* Click the "Cancel Selected Events" on the confirmation page.

For systems with Management entitlements, simply remove the systems from the action:

* Click "Schedule" on the top navigation bar, then "Pending Actions" in the left navigation bar.
* Click on the numeral in the "In Progress" column of the row for the action you want to remove.
* Select the systems for removal from the action and then click on the "Unschedule Action" button.
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/18/2003 09:53:59 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 14, 7); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
24, 'Why do scheduled kernel errata fail to install?', 'By default, the kernel packages are marked to be skipped by the update agent.  You can change this configuration by running:

up2date --configure --nox

...and changing or clearing the "pkgSkipList" parameter.  You should then be able to schedule your kernel update.
'
, 0,  TO_Date( '06/14/2002 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/30/2003 04:21:47 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 11, 6); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
131, 'pvt: openssl packages', 'The latest releases of the OpenSSL packages from Red Hat include fixes for all known security vulnerabilities, including the various types of worms that float around.

Please remember that just upgrading the packages is not sufficient. You will have to restart at least your Apache server in order for the new libraries to be loaded by the running Apache process.

More details about the applicable OpenSSL errata can be found at:

https://rhn.redhat.com/errata/RHSA-2002-160.html
and
https://rhn.redhat.com/network/errata/errata_details.pxt?eid=1143
'
, 1,  TO_Date( '12/19/2002 07:33:20 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:10 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 4, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
148, 'pvt: delayed response', 'Due to significant interest & volume in Spacewalk services, we have been unable to respond to your question in a timely manner.  We apologize for the delay and any inconvenience this delay may have caused you.  In response to your question, below is a response to your question.  If this solution does not resolve your issue, please resubmit with additional information.
'
, 1,  TO_Date( '02/05/2003 12:41:33 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/03/2003 11:24:13 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 39, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
168, 'pvt: New To Linux', 'This address is intended for support questions from paid subscribers and is related only to Spacewalk. General Red Hat Linux support is not available from this address.  If you are registered with Red Hat Support, you may address your questions at:
http://www.redhat.com/support

If you have not already done so, you can activate your product and receive advanced support at:

https://www.redhat.com/apps/support/

Even if you are not registered with Red Hat Support, you are welcome to browse
our documentation and online resources available at:

https://www.redhat.com/docs/

You may also get access to Tips, FAQs, and online HOWTOs to guide you through
Linux-related tasks if you start looking from our Support Resources Home Page
available at:

https://www.redhat.com/apps/support/resources/

The Red Hat mailing lists are also good venues for finding answers to your
questions. For more information on the Red Hat mailing lists, please see:

http://www.redhat.com/mailing-lists/

If you would like to report a bug or a problem with a component of the Red Hat Linux distribution, we encourage you to visit our bug tracking system and file a bug report at:

http://bugzilla.redhat.com/bugzilla
'
, 1,  TO_Date( '02/13/2003 04:23:15 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:10 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 6, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
169, 'How do I change my email address?', 'To change your email:

* Log in to the Spacewalk website with your existing username and password.
* If you are not at Your Spacewalk page, click its link in the top navigation bar.
* Click "Your Account" in the left navigation bar.
* Click "Change Email"
* Type your new email in field.
* Click the "Send Verification" or "Update" button.'
, 0,  TO_Date( '02/13/2003 10:03:56 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/13/2003 09:15:55 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 16, 2); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
170, 'pvt: How to entitle system in my Spacewalk', '* Once the system is registered, log in at https://rhn.redhat.com.
* Click "Systems" in the top navigation bar, then "System Entitlements" on the left.
* Select the appropriate entitlement level for the new system and click "Update Entitlements."'
, 1,  TO_Date( '02/13/2003 10:36:28 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '05/15/2003 09:36:58 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 54, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
188, 'pvt: system on a closed net , but still want to update', 'Spacewalk Management Satellite Server provides for local management of system profiles, thus allowing for completely disconnected operation from external networks.
More information, please follow this link:
https://rhn.redhat.com/info/purchase_info.pxt
'
, 1,  TO_Date( '02/18/2003 09:35:22 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/07/2003 11:03:00 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 8, 1); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
189, 'What are the differences between Update, Management, and Demo Accounts?', 'Update service level subscriptions to Spacewalk allow individuals to register one or more systems, manage these systems independently, receive priority access to Spacewalk, and download Easy ISOs (full versions of Red Hat Linux). Update subscriptions are $60 per system and renew annually. Customers may receive also limited time (less than one year) Update subscriptions with the Red Hat Linux distribution products.

Management service level subscriptions to Spacewalk allow organizations to manage multiple systems, individually or in groups of systems. Management subscriptions efficiently combine the power and flexibility of fine-grained control with the scalability to support thousands of systems.

Demo refers to our complimentary service level. Any user may receive one Demo account with Spacewalk to receive notifications and system updates. Demo users are asked to take a short survey every 60 days in order to provide Red Hat with valued customer input and to validate that the account is still active. Please note that there can be only one demo account per email address.

Note: A Demo account does not provide guaranteed access to errata or bandwidth allocation during peak times, as these resources are reserved for paying subscribers. For this reason, Red Hat strongly recommends purchasing at least an Update service level if you are using your Linux system for home or business production use.

For more information, please follow this link:
http://www.redhat.com/software/rhn/offerings'
, 0,  TO_Date( '02/18/2003 10:53:18 PM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '04/21/2003 12:08:01 PM', 'MM/DD/YYYY HH:MI:SS AM')
, 48, 4); 
INSERT INTO RHNFAQ ( ID, SUBJECT, DETAILS, PRIVATE, CREATED, MODIFIED, USAGE_COUNT,
CLASS_ID ) VALUES ( 
190, 'pvt:How can i delete my account in Spacewalk?', 'Sorry,you can not delete your account in Spacewalk now. But your account will be disabled if you do not accept the survey per 60 days.'
, 1,  TO_Date( '02/19/2003 04:22:18 AM', 'MM/DD/YYYY HH:MI:SS AM'),  TO_Date( '03/31/2003 09:26:10 AM', 'MM/DD/YYYY HH:MI:SS AM')
, 25, 1); 
COMMIT;
