--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
rhnContentSourceFilter
(
        id		number NOT NULL
			constraint rhn_csf_id_pk primary key,
        source_id		number
			constraint rhn_csf_source_fk
                                references rhnContentSource (id),
        sort_order	number NOT NULL,
        flag            varchar2(1) NOT NULL
                        check (flag in ('+','-')),
        filter          varchar2(4000) NOT NULL,
        created         timestamp with local time zone default(current_timestamp) NOT NULL,
        modified        timestamp with local time zone default(current_timestamp) NOT NULL
)
	enable row movement
  ;


create sequence rhn_csf_id_seq start with 500;

CREATE UNIQUE INDEX rhn_csf_sid_so_uq
    ON rhnContentSourceFilter (source_id, sort_order)
    tablespace [[64k_tbs]];

