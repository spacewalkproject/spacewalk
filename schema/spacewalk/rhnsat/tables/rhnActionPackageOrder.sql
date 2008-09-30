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
create table rhnActionPackageOrder (
   action_package_id       number
                           constraint rhn_act_pkg_apid_nn not null
                           constraint rhn_act_pkg_apid_fk references rhnActionPackage(id)
                           on delete cascade,
   package_order           number
                           constraint rhn_act_pkg_order_nn not null
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
	enable row movement
initrans 32;

create index rhn_act_pkg_apid_idx
on rhnActionPackageOrder (action_package_id)
tablespace [[32m_tbs]]
storage ( freelists 16 )
initrans 32;


-- $Log$
