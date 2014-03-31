-- oracle equivalent source sha1 86e2f48e2c3247c1bd44b479df8fcb5703c038a5
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
CREATE OR REPLACE FUNCTION rhn_actionchain_mod_trig_fun() RETURNS TRIGGER
    AS
    $$
    BEGIN
        new.modified := current_timestamp;
        RETURN new;
    END;
    $$
    LANGUAGE PLPGSQL;

CREATE TRIGGER rhn_actionchain_mod_trig
    BEFORE INSERT OR UPDATE ON rhnActionChain
    FOR EACH ROW
    EXECUTE PROCEDURE rhn_actionchain_mod_trig_fun();
