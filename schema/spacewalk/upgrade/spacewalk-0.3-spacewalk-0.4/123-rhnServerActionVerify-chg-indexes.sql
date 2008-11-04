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

drop index rhn_sactionvm_sanec_uq;
create unique index rhn_sactionvm_sanec_uq
        on rhnServerActionVerifyMissing(
                server_id, action_id,
                package_name_id, package_evr_id, package_arch_id,
                package_capability_id )
        tablespace [[4m_tbs]]
        storage ( freelists 16 )
        initrans 32;

drop index rhn_sactionvr_sanec_uq;
create unique index rhn_sactionvr_sanec_uq
        on rhnServerActionVerifyResult(
                server_id, action_id,
                package_name_id, package_evr_id, package_arch_id,
                package_capability_id )
        tablespace [[4m_tbs]]
        storage ( freelists 16 )
        initrans 32;

-- $Log$
-- Revision 1  2008/11/03
-- bugzilla: 456539 -- adding package_arch_id to indexes

