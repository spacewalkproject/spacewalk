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

create table
rhnActionDaemonConfig
(
	action_id		number
				constraint rhn_actiondc_aid_nn not null
				constraint rhn_actiondc_aid_fk
					references rhnAction(id)
					on delete cascade,
        interval                number
                                constraint rhn_actiondc_int_nn not null,
        restart                 char(1) default 'Y'
                                constraint rhn_actiondc_rest_nn not null
                                constraint rhn_actiondc_rest_ck check 
                                    (restart in ('Y','N')),
	created			date default(sysdate)
				constraint rhn_actiondc_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actiondc_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_actiondc_aid_uq
	on rhnActionDaemonConfig ( action_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_actiondc_mod_trig
before insert or update on rhnActionDaemonConfig
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/03/15 21:39:54  misa
-- bugzilla: 118149  Schema done
--
--
