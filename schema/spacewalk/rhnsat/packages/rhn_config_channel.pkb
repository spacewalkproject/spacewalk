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
PACKAGE BODY rhn_config_channel
IS
    FUNCTION action_diff_revision_status(action_config_revision_id_in IN NUMBER)
    RETURN VARCHAR2
    IS
    	failure_reason VARCHAR2(4000);
	result_is_null NUMBER;
	result_exists NUMBER;
    BEGIN
    	-- result_is_null obviously wants NVL2, but stupid 8.1.7.3.0 doesn't
	-- have that.  Or case.  So we're using union, instead.
	select extant, is_null, reason
	into   result_exists, result_is_null, failure_reason
	from   (
        	SELECT ACRR.action_config_revision_id extant,
        	       1 is_null, -- NVL2(ACRR.result, 0, 1),
        	       CFF.name reason
        	  FROM rhnConfigFileFailure CFF,
        	       rhnActionConfigRevisionResult ACRR,
        	       rhnActionConfigRevision ACR
        	 WHERE ACR.id = action_config_revision_id_in
        	   AND ACR.id = ACRR.action_config_revision_id (+)
        	   and acrr.result is null
        	   AND ACR.failure_id = CFF.id (+)
        	union all
        	SELECT ACRR.action_config_revision_id extant, 
        	       0 is_null, -- NVL2(ACRR.result, 0, 1),
        	       CFF.name reason
        	  FROM rhnConfigFileFailure CFF,
        	       rhnActionConfigRevisionResult ACRR,
        	       rhnActionConfigRevision ACR
        	 WHERE ACR.id = action_config_revision_id_in
        	   AND ACR.id = ACRR.action_config_revision_id (+)
        	   and acrr.result is not null
        	   AND ACR.failure_id = CFF.id (+)
		);
	 
    	IF failure_reason IS NOT NULL
	THEN
	    RETURN failure_reason;
	END IF;

    	IF result_exists IS NOT NULL
	THEN
	    IF result_is_null = 1
	    THEN
	    	RETURN 'No differences';
	    END IF;
	    
	    RETURN 'Differences exist';
	END IF;

    	RETURN NULL;
    END action_diff_revision_status;

    FUNCTION get_user_chan_access(config_channel_id_in IN NUMBER, user_id_in IN NUMBER)
    RETURN NUMBER
    IS
    	server_id NUMBER;
	org_matches NUMBER;
	global_channel VARCHAR2(30);
	any_visible_servers_subscribed NUMBER;
    BEGIN

    	org_matches := 0;
	BEGIN
    	  SELECT 1 INTO org_matches
	    FROM rhnConfigChannel CC,
	         web_contact WC
	   WHERE WC.id = user_id_in
	     AND CC.id = config_channel_id_in
	     AND WC.org_id = CC.org_id;
	EXCEPTION
	  WHEN NO_DATA_FOUND
	    THEN RETURN 0;
	END;
	   
	global_channel := 'unknown';
 	SELECT CCT.label INTO global_channel
	  FROM rhnConfigChannel CC,
	       rhnConfigChannelType CCT
	 WHERE CC.id = config_channel_id_in
	   AND CCT.id = CC.confchan_type_id;

    	IF (rhn_user.check_role_implied(user_id_in, 'config_admin') = 1) AND (global_channel = 'normal')
	THEN
	    RETURN 1;
	END IF;

    	any_visible_servers_subscribed := 0;
	BEGIN
    	  SELECT 1 INTO any_visible_servers_subscribed
	    FROM DUAL
           WHERE EXISTS (
	     SELECT SCC.server_id
	       FROM rhnServerConfigChannel SCC,
	            rhnUserServerPermsDupes USPD
	      WHERE USPD.user_id = user_id_in
	        AND USPD.server_id = SCC.server_id
	        AND SCC.config_channel_id = config_channel_id_in
	   );
	EXCEPTION
	  WHEN NO_DATA_FOUND
	    THEN RETURN 0;
	END;

	RETURN any_visible_servers_subscribed;
	
    END get_user_chan_access;

    FUNCTION get_user_revision_access(config_revision_id_in IN NUMBER, user_id_in IN NUMBER)    
    RETURN NUMBER
    IS
    	config_channel_id NUMBER;
    BEGIN

    BEGIN
    	SELECT CF.config_channel_id INTO config_channel_id
	  FROM rhnConfigFile CF,
	       rhnConfigRevision CR
	 WHERE CF.id = CR.config_file_id
	   AND CR.id = config_revision_id_in;
    EXCEPTION
	  WHEN NO_DATA_FOUND
	   THEN RETURN 0;	   
    END;

	RETURN rhn_config_channel.get_user_chan_access(config_channel_id, user_id_in);
    END get_user_revision_access;
    
    FUNCTION get_user_file_access(config_file_id_in IN NUMBER, user_id_in IN NUMBER)    
    RETURN NUMBER
    IS
    	config_channel_id NUMBER;
    BEGIN

    BEGIN    
        SELECT CF.config_channel_id INTO config_channel_id    	
	  FROM rhnConfigFile CF
	 WHERE CF.id = config_file_id_in;
	EXCEPTION
	  WHEN NO_DATA_FOUND
	    THEN RETURN 0;
    END;

	RETURN rhn_config_channel.get_user_chan_access(config_channel_id, user_id_in);
    END get_user_file_access;
    
END rhn_config_channel;
/
SHOW ERRORS

--
-- Revision 1.6  2004/03/22 19:52:02  pjones
-- bugzilla: none -- 8.1.7 compat changes
--
-- Revision 1.5  2004/02/09 17:30:42  bretm
-- bugzilla:  109398
--
-- o  remove crackrock function rhn_config_channel.get_config_channel_server,
--    greps done against webcode, sql, and backend code to ensure it wasn't
--    used elsewhere
-- o  correctly determine if a user_id has access to a particular
--    config_channel_id
--
-- Revision 1.4  2004/02/05 19:21:00  bretm
-- bugzilla:  109938
--
-- security fix for viewing config channel info
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
