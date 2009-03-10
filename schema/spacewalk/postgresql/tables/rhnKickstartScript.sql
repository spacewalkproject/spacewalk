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

create sequence rhn_ksscript_id_seq;

create table
rhnKickstartScript
(
	id			numeric
				constraint rhn_ksscript_id_pk primary key,
	kickstart_id		numeric
				not null
				constraint rhn_ksscript_ksid_fk
				references rhnKSData(id)
				on delete cascade,
	position		numeric
				not null,
	script_type		varchar(4)
				not null
				constraint rhn_ksscript_st_ck
				check (script_type in ('pre','post')),
	chroot			char(1) default ('Y')
				not null
				constraint rhn_ksscript_chroot_ck
				check (chroot in ('Y','N')),
	interpreter		varchar(80),
	data			bytea,
	created			date default (current_date)
				not null,
	modified		date default (current_date)
				not null,
                                constraint rhn_ksscript_ksid_pos_uq
                                unique ( kickstart_id, position )
)
  ;

create index rhn_ksscript_id_idx
	on rhnKickstartScript( id )
--	tablespace [[2m_tbs]]
        ;
create index rhn_ksscript_ksid_pos_idx
	on rhnKickstartScript( kickstart_id, position )
--	tablespace [[8m_tbs]]
       ;

/*
create or replace trigger
rhn_ksscript_mod_trig
before insert or update on rhnKickstartSession
for each row
begin
	:new.modified := sysdate;
end rhn_ksscript_mod_trig;
/
show errors
*/
--
--
-- Revision 1.3  2004/09/23 19:56:35  pjones
-- bugzilla: none -- char(4) should be varchar2(4)
--
-- Revision 1.2  2004/09/22 14:16:23  pjones
-- bugzilla: 133072 -- don't normalize script type
--
-- Revision 1.1  2004/09/21 16:01:20  pjones
-- bugzilla: 133072 -- add tables for shughes
--
