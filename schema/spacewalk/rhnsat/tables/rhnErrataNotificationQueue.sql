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
rhnErrataNotificationQueue
(
	errata_id		number
				constraint rhn_enqueue_eid_nn not null
				constraint rhn_enqueue_eid_fk
					references rhnErrata(id)
					on delete cascade,
        org_id                  number
                            	constraint rhn_enqueue_oid_nn not null
                            	constraint rhn_enqueue_oid_fk
                                	references web_customer(id)
					on delete cascade,
	next_action		date default(sysdate),
        channel_id              number
                                constraint rhn_enqueue_nn NOT NULL
				constraint rhn_enqueue_cid_fk
					references rhnChannel(id)
					on delete cascade,
	created			date default(sysdate)
				constraint rhn_enqueue_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_enqueue_modified_nn not null
)
	enable row movement
  ;

create index rhn_enqueue_eid_idx
	on rhnErrataNotificationQueue ( errata_id, org_id )
	tablespace [[4m_tbs]]
  ;
alter table rhnErrataNotificationQueue add constraint rhn_enqueue_eoid_uq
	unique ( errata_id, org_id );

create index rhn_enqueue_na_eid_idx
	on rhnErrataNotificationQueue ( next_action, errata_id )
	tablespace [[8m_tbs]]
  ;

create or replace trigger
rhn_enqueue_mod_trig
before insert or update on rhnErrataNotificationQueue
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.4  2003/08/14 20:01:14  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.3  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.2  2003/02/25 18:46:37  cturner
-- add org id to the errata notification queue so that we can split big jobs up properly
--
-- Revision 1.1  2003/02/14 16:08:57  pjones
-- errata notification queue
--
