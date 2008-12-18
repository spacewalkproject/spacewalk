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
rhnActionPackageAnswerfile
(
	action_package_id number
			constraint rhn_act_p_af_apid_nn not null
			constraint rhn_act_p_af_apid_fk
				references rhnActionPackage(id)
				on delete cascade,
	answerfile	blob,
	created		date default(sysdate)
			constraint rhn_act_p_af_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_act_p_af_mod_nn not null
)
	tablespace [[blob]]
	enable row movement
  ;

create index rhn_act_p_af_aid_idx
	on rhnActionPackageAnswerfile( action_package_id )
	tablespace [[2m_tbs]]
	nologging;

create or replace trigger
rhn_act_p_af_mod_trig
before insert or update on rhnActionPackageAnswerfile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.3  2004/02/10 23:07:21  pjones
-- bugzilla: none -- tablename fix
--
-- Revision 1.2  2004/02/10 22:33:16  pjones
-- bugzilla: none -- update rhnActionPackageAnswerfile to reference new pk
--
-- Revision 1.1  2004/02/10 22:20:13  pjones
-- bugzilla: none -- initial table to hold answerfile data
--
