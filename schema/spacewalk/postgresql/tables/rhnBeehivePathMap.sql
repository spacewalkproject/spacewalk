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
-- XXX is this apropriate for sat?

create table rhnBeehivePathMap
(
    path            varchar(128)
                    not null
                    constraint rhn_beehive_path_map_p_pk primary key
--                  using index tablespace [[64k_tbs]]
                    ,
    beehive_path    varchar(128)
                    not null,
    ftp_path        varchar(128)
                    not null,
    created         date default CURRENT_DATE,
    modified        date default CURRENT_DATE
)
  ;

/*
create or replace trigger
rhn_beehive_path_map_mod_trig
before insert or update on rhnBeehivePathMap
for each row
begin
    :new.modified := SYSDATE;
end rhn_beehive_mod_trig;
/
show errors

--
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
