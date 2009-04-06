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

--data for rhn_strategies (has a sequence!!!)

insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (nextval('rhn_strategies_recid_seq')),'Broadcast-NoAck',
    'Sent=100',NULL,'Broadcast','No');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (nextval('rhn_strategies_recid_seq')),'Escalate-OneAck',
    'Acked>0','Incomplete=0','Escalate','One');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (nextval('rhn_strategies_recid_seq')),'Escalate-AllAck',
    'Acked=100','(Failed>50)|(Incomplete=0)','Escalate','All');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (nextval('rhn_strategies_recid_seq')),'Broadcast-OneAck',
    'Acked>0',NULL,'Broadcast','One');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (nextval('rhn_strategies_recid_seq')),'Broadcast-AllAck',
    'Acked=100',NULL,'Broadcast','All');

--Increment the sequence so the next value is 12
-- These select 6 through 11.
select nextval('rhn_strategies_recid_seq')) from dual; 
select nextval('rhn_strategies_recid_seq')) from dual;
select nextval('rhn_strategies_recid_seq')) from dual;
select nextval('rhn_strategies_recid_seq')) from dual;
select nextval('rhn_strategies_recid_seq')) from dual;
select nextval('rhn_strategies_recid_seq')) from dual;

insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (nextval('rhn_strategies_recid_seq')),'Escalate-NoAck',
    'Sent>0','Failed>0|Incomplete>0','Escalate','No');
commit;

--
--Revision 1.6  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.5  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.4  2004/05/28 22:25:50  pjones
--bugzilla: none -- no comments after ;, they don't work.
--
--Revision 1.3  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.2  2004/04/22 19:05:45  kja
--Added the 24 x 7 schedule data.  Corrected logic for skipping sequence numbers
--in rhn_notification_formats_data.sql and rhn_strategies_data.sql.
--
--Revision 1.1  2004/04/22 17:49:49  kja
--Added data for the reference tables.
--
