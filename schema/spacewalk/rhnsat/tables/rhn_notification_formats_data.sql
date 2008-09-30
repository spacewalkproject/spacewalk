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
--
--
--
-- 
--

--data for rhn_notification_formats (uses sequence!!!)

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( rhn_ntfmt_recid_seq.nextval,NULL,'Default Format','^[alert id] | ^[timestamp]','^[alert id] | ^[timestamp]',70,1920,NULL);

--Skip #2
select rhn_ntfmt_recid_seq.nextval from dual;

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( rhn_ntfmt_recid_seq.nextval,NULL,'New Default (2.15)','^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"]','This is a Spacewalk Monitoring Satellite event notification.\n\nTime:      ^[timestamp:"%a %b %d, %H:%M:%S %Z"]\nState:     ^[probe state]\nHost:      ^[hostname] (^[host IP])\nCheck:     ^[probe description]\nMessage:   ^[probe output]\nRun from:  ^[satellite description]\n\nTo acknowledge, reply to this message with this subject line:\n     ACK ^[alert id]\n\nTo immediately escalate, reply to this message with this subject line:\n     NACK ^[alert id]',150,1920,NULL);

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( rhn_ntfmt_recid_seq.nextval,NULL,'New Default (2.18)','^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"]','This is Spacewalk Monitoring Satellite notification ^[alert id].\n\nTime:      ^[timestamp:"%a %b %d, %H:%M:%S %Z"]\nState:     ^[probe state]\nHost:      ^[hostname] (^[host IP])\nCheck:     ^[probe description]\nMessage:   ^[probe output]\nRun from:  ^[satellite description]',150,1920,'\n\nTo acknowledge, reply to this message within ^[ack wait] minutes with this subject line:\n     ACK ^[alert id]\n\nTo immediately escalate, reply to this message within ^[ack wait] minutes with this subject line:\n     NACK ^[alert id]');

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( rhn_ntfmt_recid_seq.nextval,NULL,'Pager Default (3.6)',NULL,'^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"], notification ^[alert id]',0,200,NULL);
commit;

--
--Revision 1.10  2005/02/15 21:40:35  jslagle
--bz #141966
--Improve notification format
--
--Revision 1.9  2004/12/01 15:10:43  kja
--Bugzilla 137559: Replace "Red Hat Command Center" with "Spacewalk Monitoring Satellite."
--
--Revision 1.8  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.7  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.6  2004/05/28 19:44:56  pjones
--bugzilla: none -- make it use right schema names...
--
--Revision 1.5  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.4  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.3  2004/04/22 19:05:45  kja
--Added the 24 x 7 schedule data.  Corrected logic for skipping sequence numbers
--in rhn_notification_formats_data.sql and rhn_strategies_data.sql.
--
--Revision 1.2  2004/04/22 17:53:18  kja
--Changed NOCpulse to Red Hat.
--
--Revision 1.1  2004/04/22 17:49:49  kja
--Added data for the reference tables.
--
