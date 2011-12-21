--
-- Copyright (c) 2008--2011 Red Hat, Inc.
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
    
END rpm;
/
SHOW ERRORS;

