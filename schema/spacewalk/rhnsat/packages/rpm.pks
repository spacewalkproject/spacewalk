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
--
-- PL/SQL version of rpmvercompare
-- 

CREATE OR REPLACE PACKAGE rpm AS
    FUNCTION vercmp(
        e1 VARCHAR2, v1 VARCHAR2, r1 VARCHAR2, 
        e2 VARCHAR2, v2 VARCHAR2, r2 VARCHAR2)
    RETURN NUMBER
        DETERMINISTIC
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmp, WNDS, RNDS);

    FUNCTION vercmpCounter
    return NUMBER
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmpCounter, WNDS, RNDS);

    FUNCTION vercmpResetCounter
    return NUMBER
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmpResetCounter, WNDS, RNDS);
    
END rpm;
/
SHOW ERRORS;

--
-- Revision 1.4  2002/05/10 22:08:23  pjones
-- id/log
--
-- Revision 1.3  2002/04/02 23:19:44  misa
-- Added the comparison counter and assorted functions for handling it.
--
-- Revision 1.2  2002/03/21 20:21:24  misa
-- For some reason this doesn't work. I'll further investigate it.
--
-- Revision 1.1  2002/03/21 20:14:10  misa
-- The packaged version of the PL/SQL rpmvercmp
--
