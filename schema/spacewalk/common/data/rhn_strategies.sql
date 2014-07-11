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

--data for rhn_strategies (has a sequence!!!)

insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (sequence_nextval('rhn_strategies_recid_seq'),'Broadcast-NoAck',
    'Sent=100',NULL,'Broadcast','No');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (sequence_nextval('rhn_strategies_recid_seq'),'Escalate-OneAck',
    'Acked>0','Incomplete=0','Escalate','One');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (sequence_nextval('rhn_strategies_recid_seq'),'Escalate-AllAck',
    'Acked=100','(Failed>50)|(Incomplete=0)','Escalate','All');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (sequence_nextval('rhn_strategies_recid_seq'),'Broadcast-OneAck',
    'Acked>0',NULL,'Broadcast','One');
insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (sequence_nextval('rhn_strategies_recid_seq'),'Broadcast-AllAck',
    'Acked=100',NULL,'Broadcast','All');

--Increment the sequence so the next value is 12
-- These select 6 through 11.
select sequence_nextval('rhn_strategies_recid_seq') from dual;
select sequence_nextval('rhn_strategies_recid_seq') from dual;
select sequence_nextval('rhn_strategies_recid_seq') from dual;
select sequence_nextval('rhn_strategies_recid_seq') from dual;
select sequence_nextval('rhn_strategies_recid_seq') from dual;
select sequence_nextval('rhn_strategies_recid_seq') from dual;

insert into rhn_strategies(recid,name,comp_crit,esc_crit,contact_strategy,
ack_completed) 
    values (sequence_nextval('rhn_strategies_recid_seq'),'Escalate-NoAck',
    'Sent>0','Failed>0|Incomplete>0','Escalate','No');
commit;

