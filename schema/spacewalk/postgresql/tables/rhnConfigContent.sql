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

--create sequence rhn_confcontent_id_seq;

create table
rhnConfigContent
(
	id			numeric not null
				constraint rhn_confcontent_id_pk primary key
--					using index tablespace [[2m_tbs]]
                                ,
	contents		bytea,
	file_size		numeric,
	md5sum			varchar(64) not null,
	is_binary	        char(1) default('N') not null
				constraint rhn_confcontent_isbin_ck
					check (is_binary in ('Y','N')),
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null
)
--	tablespace [[blob]]
;

create index rhn_confcontent_md5_uq
	on rhnConfigContent( md5sum )
--	tablespace [[2m_tbs]]
  ;

/*create or replace trigger
rhn_confcontent_mod_trig
before insert or update on rhnConfigContent
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/

--
--
-- Revision 1.4  2004/01/15 23:06:41  pjones
-- bugzilla: none -- make sure rhnConfigContent gets created in its own
-- tablespace
--
-- Revision 1.3  2003/11/13 23:59:16  cturner
-- bugzilla: 109861, add is_binary to config contents to flag if a file is to be considered binary by the web ui
--
-- Revision 1.2  2003/11/10 16:07:45  pjones
-- bugzilla: 109083 -- add file size
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
