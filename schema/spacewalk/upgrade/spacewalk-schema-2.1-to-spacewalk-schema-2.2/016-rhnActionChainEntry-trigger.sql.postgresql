-- oracle equivalent source sha1 7715f65e1a0b48c5cc203e91294b89685f9e2033
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
CREATE OR REPLACE FUNCTION rhn_actchainent_mod_trig_fun() RETURNS TRIGGER
    AS
    $$
    BEGIN
        new.modified := current_timestamp;
        RETURN new;
    END;
    $$
    LANGUAGE PLPGSQL;

CREATE TRIGGER rhn_actchainent_mod_trig
    BEFORE INSERT OR UPDATE ON rhnActionChainEntry
    FOR EACH ROW
    EXECUTE PROCEDURE rhn_actchainent_mod_trig_fun();
