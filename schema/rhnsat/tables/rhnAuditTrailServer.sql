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
-- $Id$
--
-- associate servers with audit actions
--
-- EXCLUDE: all

create table
rhnAuditTrailServer
(
	trail_id	number
			constraint rhn_atrailserver_tid_nn not null
			constraint rhn_atrailserver_tid_fk
				references rhnAuditTrail(id),
	server_id	number
			constraint rhn_atrailserver_sid_nn not null
			constraint rhn_atrailserver_sid_fk
				references rhnServer(id)
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_atrailserver_tid_sid_idx
	on rhnAuditTrailServer(trail_id, server_id)
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create index rhn_atrailserver_sid_uid_idx
	on rhnAuditTrailServer(server_id, trail_id)
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/12/02 15:19:26  pjones
-- audit trail schema
--
