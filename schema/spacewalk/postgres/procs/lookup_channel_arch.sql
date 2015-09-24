-- oracle equivalent source sha1 afa60e5424b69a0d10f6b7060b87ba10d667dd68
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/procs/lookup_channel_arch.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
CREATE OR REPLACE FUNCTION
LOOKUP_CHANNEL_ARCH(label_in IN VARCHAR)
RETURNS NUMERIC 
AS $$
DECLARE
        channel_arch_id         NUMERIC;
BEGIN
        SELECT id
          INTO channel_arch_id
          FROM rhnChannelArch
         WHERE label = label_in;

	IF NOT FOUND THEN 
		perform rhn_exception.raise_exception('channel_arch_not_found');
	END IF;

	return channel_arch_id;
END;
$$ LANGUAGE plpgsql;
