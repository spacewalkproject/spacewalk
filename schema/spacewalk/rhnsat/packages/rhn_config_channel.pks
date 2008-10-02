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

--
-- Revision 1.4  2004/02/09 17:30:42  bretm
-- bugzilla:  109398
--
-- o  remove crackrock function rhn_config_channel.get_config_channel_server,
--    greps done against webcode, sql, and backend code to ensure it wasn't
--    used elsewhere
-- o  correctly determine if a user_id has access to a particular
--    config_channel_id
--
-- Revision 1.3  2003/12/02 20:33:58  bretm
-- bugzilla:  108651
--
-- ugh.  it's diff, not deploy.  not sure if deploy even uses rhnActionConfigRevisionResult...
--
-- Revision 1.2  2003/12/01 22:54:14  bretm
-- bugzilla:  101303
--
-- added a function for determining the status of a config file during a verification action
--
-- painful schema is
-- really freakin annoying
-- cherry blossoms fall
--
-- Revision 1.1  2003/11/13 19:22:49  cturner
-- refactor some permission checks into a plsql package to simplify some web code; necessary so sysadmins can view some config files without being config admins
--
