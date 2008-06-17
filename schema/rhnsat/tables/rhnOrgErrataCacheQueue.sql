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

create table rhnOrgErrataCacheQueue
(
        org_id          number
                        constraint rhn_oecq_oid_nn not null
                        constraint rhn_oecq_oid_fk
                                references web_customer(id)
				on delete cascade,
        server_count    number constraint rhn_oecq_sc_nn not null,
        processed       number default(0)
                        constraint rhn_oecq_oid_processed_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_oecq_oid_uq
        on rhnOrgErrataCacheQueue(org_id)
        tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- make it nologging.  went live 12/14/01
alter table rhnOrgErrataCacheQueue nologging;
alter index rhn_oecq_oid_uq nologging;

-- this takes about 2 minutes to build

-- $Log$
-- Revision 1.13  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/05/10 21:54:45  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
-- Revision 1.10  2002/03/20 18:02:48  cturner
-- put ELDS 7.2 channels after 7.2.  also remove an unneded alter index
--
-- Revision 1.9  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.8  2002/03/11 17:51:28  cturner
-- more optimization of errata cache sql
--
-- Revision 1.7  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
