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
-- $Id$
-- 

create table demo_log (
    org_id      number,
    server_id   number
)
	enable row movement
;

create index dl_oid_sid_idx
    on demo_log (org_id, server_id)
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32
    nologging;


-- table to hold which servers got unentitled for orgs
-- that were using the demo entitlement.
--
-- server_id will be 0 if nothing could be unentitled.
