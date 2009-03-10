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
--
-- CVE/CAN strings, for use with errata.
-- See http://cve.mitre.org/
--/

CREATE TABLE
rhnCVE
(
        id              numeric
			not null
                        constraint rhn_cve_id_pk primary key
--			using index tablespace [[2m_tbs]]
                        ,
        name            varchar(13) -- like:  CXX-XXXX-XXXX
			not null 
                        constraint rhn_cve_name_uq unique
--                      using index tablespace [[2m_tbs]]
)
  ;

create sequence rhn_cve_id_seq;

--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/05/20 15:39:54  pjones
-- more grants, fix typos, rename the sequence
--
-- Revision 1.1  2002/05/20 15:34:18  pjones
-- add CVE stuff for bretm/mjc
--
