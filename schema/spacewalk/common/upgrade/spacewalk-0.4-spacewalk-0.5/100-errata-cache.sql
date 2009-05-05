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
-- Generated from ../common: DO NOT EDIT HERE!
--



DROP INDEX rhn_snec_eid_sid_idx;

DROP INDEX rhn_snec_sid_eid_idx;

DROP INDEX rhn_snec_oid_eid_sid_idx;

DROP TABLE rhnServerNeededErrataCache;

ALTER TABLE rhnServerNeededPackageCache
    DROP CONSTRAINT rhn_sncp_oid_nn;

ALTER TABLE rhnServerNeededPackageCache
    DROP CONSTRAINT rhn_sncp_oid_fk;

DROP INDEX rhn_snpc_oid_idx;

ALTER TABLE rhnServerNeededPackageCache
    DROP COLUMN org_id;

DROP INDEX rhn_snpc_pid_idx;

DROP INDEX rhn_snpc_sid_idx;

DROP INDEX rhn_snpc_eid_idx;

ALTER TABLE rhnServerNeededPackageCache RENAME TO rhnServerNeededCache;

CREATE INDEX rhn_snc_pid_idx
    ON rhnServerNeededCache (package_id)
    PARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snc_sid_idx
    ON rhnServerNeededCache (server_id)
    PARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snc_eid_idx
    ON rhnServerNeededCache (errata_id)
    PARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_snc_speid_idx
    ON rhnServerNeededCache (server_id, package_id, errata_id)
    PARALLEL
    TABLESPACE [[128m_tbs]]
    NOLOGGING;

@../views/common/rhnServerNeededPackageCache.sql

@../views/common/rhnServerNeededErrataCache.sql

@../views/rhnServerNeededView.sql

@../views/common/rhnServerErrataTypeView.sql

@../procs/queue_server.sql

@../procs/delete_errata.sql

@../procs/delete_server.sql

