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

CREATE OR REPLACE
PACKAGE rhn_config_channel
IS
    FUNCTION get_user_chan_access(config_channel_id_in IN NUMBER, user_id_in IN NUMBER) RETURN NUMBER;
    FUNCTION get_user_revision_access(config_revision_id_in IN NUMBER, user_id_in IN NUMBER) RETURN NUMBER;
    FUNCTION get_user_file_access(config_file_id_in IN NUMBER, user_id_in IN NUMBER) RETURN NUMBER;
    
    FUNCTION action_diff_revision_status(action_config_revision_id_in IN NUMBER) RETURN VARCHAR2;
    
END rhn_config_channel;
/
SHOW ERRORS
