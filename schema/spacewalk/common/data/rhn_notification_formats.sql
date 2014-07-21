--
-- Copyright (c) 2008--2013 Red Hat, Inc.
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
    values ( sequence_nextval('rhn_ntfmt_recid_seq'),NULL,'Default Format','^[alert id] | ^[timestamp]','^[alert id] | ^[timestamp]',70,1920,NULL);

--Skip #2
select sequence_nextval('rhn_ntfmt_recid_seq') from dual;

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( sequence_nextval('rhn_ntfmt_recid_seq'),NULL,'New Default (2.15)','^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"]','This is a Spacewalk Monitoring Satellite event notification.\n\nTime:      ^[timestamp:"%a %b %d, %H:%M:%S %Z"]\nState:     ^[probe state]\nHost:      ^[hostname] (^[host IP])\nCheck:     ^[probe description]\nMessage:   ^[probe output]\nRun from:  ^[satellite description]\n\nTo acknowledge, reply to this message with this subject line:\n     ACK ^[alert id]\n\nTo immediately escalate, reply to this message with this subject line:\n     NACK ^[alert id]',150,1920,NULL);

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( sequence_nextval('rhn_ntfmt_recid_seq'),NULL,'New Default (2.18)','^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"]','This is Spacewalk Monitoring Satellite notification ^[alert id].\n\nTime:      ^[timestamp:"%a %b %d, %H:%M:%S %Z"]\nState:     ^[probe state]\nHost:      ^[hostname] (^[host IP])\nCheck:     ^[probe description]\nMessage:   ^[probe output]\nRun from:  ^[satellite description]',150,1920,'\n\nTo acknowledge, reply to this message within ^[ack wait] minutes with this subject line:\n     ACK ^[alert id]\n\nTo immediately escalate, reply to this message within ^[ack wait] minutes with this subject line:\n     NACK ^[alert id]');

insert into rhn_notification_formats(recid,customer_id,description,
subject_format,body_format,max_subject_length,max_body_length,reply_format) 
    values ( sequence_nextval('rhn_ntfmt_recid_seq'),NULL,'Pager Default (3.6)',NULL,'^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"], notification ^[alert id]',0,200,NULL);
commit;

