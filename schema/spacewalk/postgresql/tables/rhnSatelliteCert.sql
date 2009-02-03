--
-- Copyright (c) 2009 Red Hat, Inc.
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
-- This holds our satellite cert.

create table
rhnSatelliteCert
(
	label			varchar(64) not null,
	version			numeric,
    constraint      rhn_satcert_label_version_uq unique (label, version),
--	tablespace [[64k_tbs]]
	cert			bytea not null,
	-- issued and expires are derived from the "cert" data, but we
	-- need them to search for certs that have expired.
	issued			timestamp default(CURRENT_TIMESTAMP),
	expires			timestamp default(CURRENT_TIMESTAMP),
	created			timestamp default(CURRENT_TIMESTAMP) not null,
	modified		timestamp default(CURRENT_TIMESTAMP) not null
);
