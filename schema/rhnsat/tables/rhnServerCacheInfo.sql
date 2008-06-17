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

create table
rhnServerCacheInfo
(
  server_id       number
                  constraint rhn_server_cache_info_sid_nn not null
                  constraint rhn_server_cache_info_sid_fk 
                     references rhnServer(id),
   update_time    date
)
        storage ( pctincrease 1 freelists 16 )
        initrans 32;

create unique index rhn_server_cache_info_sid_idx
        on rhnServerCacheInfo(server_id)
        tablespace [[4m_tbs]]
        storage( pctincrease 1 freelists 16 )
        initrans 32;




-- $Log$
-- Revision 1.3  2005/02/09 21:23:07  jslagle
-- Initial sql files for rhnServerCacheInfo
--
-- Revision 1.2  2005/02/09 21:12:11  jslagle
-- Changed index to unique constraint
--

