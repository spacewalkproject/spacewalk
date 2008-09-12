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
-- EXCLUDE: all

-- This really sucks.  We shouldn't have seperate databases for every mail tool.
create table
cheetah_unsubscribe
(
	address		varchar2(128)
)
	storage ( freelists 16 )
	initrans 32;

create index cheetah_unsub_address_idx
	on cheetah_unsubscribe ( address )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/11/05 16:40:22  pjones
-- bugzilla: 106071 -- these are of historical interest only, I _think_.
--
-- Revision 1.1  2003/04/15 19:08:51  pjones
-- bugzilla: 88948
--
-- ugly tables to keep track of email addresses for deleted users
-- so that they can be removed from some other database later.
--
