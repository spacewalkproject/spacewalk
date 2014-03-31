--
-- Copyright (c) 2014 SUSE
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
--

CREATE OR REPLACE TRIGGER rhn_actionchain_mod_trig
    BEFORE INSERT OR UPDATE ON rhnActionChain
    FOR EACH ROW
    BEGIN
        :new.modified := sysdate;
    END;
/
SHOW ERRORS
