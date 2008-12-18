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
create table
rhnErrataClonedTmp
(
	original_id		number
				constraint rhn_eclonedtmp_feid_nn not null
				constraint rhn_eclonedtmp_feid_fk
					references rhnErrata(id)
					on delete cascade,
	id		                                                                number
				constraint rhn_eclonedtmp_teid_nn not null
				constraint rhn_eclonedtmp_teid_fk
					references rhnErrataTmp(id)
					on delete cascade,
	created			date default(sysdate)
				constraint rhn_eclonedtmp_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_eclonedtmp_modified_nn not null
)
	enable row movement
  ;

create index rhn_eclonedtmp_feid_teid_idx
	on rhnErrataClonedTmp ( original_id, id )
	tablespace [[2m_tbs]]
  ;
alter table rhnErrataClonedTmp add constraint rhn_eclonedtmp_feid_teid_uq
	unique ( original_id, id );
alter table rhnErrataClonedTmp add constraint rhn_eclonedtmp_id_pk
        primary key ( id );

create index rhn_eclonedtmp_teid_feid_idx
	on rhnErrataClonedTmp ( id, original_id )
	tablespace [[2m_tbs]]
  ;

create or replace trigger
rhn_eclonedtmp_mod_trig
before insert or update on rhnErrataClonedTmp
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

