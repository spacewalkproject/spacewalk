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
-- data from /etc/sysconfig/installinfo

create table
rhnServerInstallInfo
(
	id		numeric not null
			constraint rhn_server_install_info_id_pk primary key
--				using index tablespace [[2m_tbs]]
                        ,
        server_id       numeric  not null
                        constraint rhn_server_install_info_sid_fk
                                references rhnServer(id)
			constraint rhn_server_install_info_sid_uq unique
--      		using index tablespace [[2m_tbs]]
                        ,
	install_method	varchar(32) not null,
	iso_status	numeric,
	mediasum	varchar(64),
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
  ;

create sequence rhn_server_install_info_id_seq;

create index rhn_s_inst_info_sid_im_idx
	on rhnServerInstallInfo(server_id, install_method)
--	tablespace [[2m_tbs]]
  ;


/*
create or replace trigger
rhn_s_inst_info_mod_trig
before insert or update on rhnServerInstallInfo
for each row
begin
	:new.modified := sysdate;
end;
/
*/
--
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2003/11/12 14:45:17  pjones
-- bugzilla: none -- put the unique in a different tablespace
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/10/23 22:44:05  misa
-- Added schema for /etc/sysconfig/installinfo
--
