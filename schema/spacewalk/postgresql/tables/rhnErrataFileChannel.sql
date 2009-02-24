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
-- This is needed because noarch and source packages can span channels
-- using the same path; i.e., noarch packages for the sparc and i386
-- channels of RHL 6.2
--

create table
rhnErrataFileChannel
(
	channel_id	numeric not null constraint rhn_efilec_cid_fk
				references rhnChannel(id)
				on delete cascade,
	errata_file_id	numeric not null
			constraint rhn_efilec_eid_fk
				references rhnErrataFile(id)
				on delete cascade,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
;

create index rhn_efilec_efid_cid_idx
	on rhnErrataFileChannel(errata_file_id, channel_id)
--	tablespace [[64k_tbs]]
  ;
alter table rhnErrataFileChannel add constraint rhn_efilec_efid_cid_uq
	unique ( errata_file_id, channel_id );

create index rhn_efilec_cid_efid_idx
	on rhnErrataFileChannel(channel_id, errata_file_id)
--	tablespace [[64k_tbs]]
  ;
