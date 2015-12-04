/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.xmlrpc.org;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgConfig;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidEntitlementException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.MigrationToSameOrgException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchOrgException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchSystemException;
import com.redhat.rhn.frontend.xmlrpc.OrgNotInTrustException;
import com.redhat.rhn.frontend.xmlrpc.PamAuthNotConfiguredException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.SatelliteOrgException;
import com.redhat.rhn.frontend.xmlrpc.ValidationException;
import com.redhat.rhn.manager.org.CreateOrgCommand;
import com.redhat.rhn.manager.org.MigrationManager;
import com.redhat.rhn.manager.org.OrgManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * OrgHandler
 * @xmlrpc.namespace org
 * @xmlrpc.doc Contains methods to access common organization management
 * functions available from the web interface.
 */
public class OrgHandler extends BaseHandler {

    private static final String VALIDATION_XSD =
            "/com/redhat/rhn/frontend/action/multiorg/validation/orgCreateForm.xsd";
    private static final String USED_KEY = "used";
    private static Logger log = Logger.getLogger(OrgHandler.class);

    /**
     * Create a new organization.
     * @param loggedInUser The current user
     * @param orgName Organization name. Must meet same criteria as in the web UI.
     * @param adminLogin New administrator login name for the new org.
     * @param adminPassword New administrator password.
     * @param prefix New administrator's prefix.
     * @param firstName New administrator's first name.
     * @param lastName New administrator's last name.
     * @param email New administrator's e-mail.
     * @param usePamAuth Should PAM authentication be used for new administrators account.
     * @return Newly created organization object.
     *
     * @xmlrpc.doc Create a new organization and associated administrator account.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "orgName", "Organization name. Must meet same
     * criteria as in the web UI.")
     * @xmlrpc.param #param_desc("string", "adminLogin", "New administrator login name.")
     * @xmlrpc.param #param_desc("string", "adminPassword", "New administrator password.")
     * @xmlrpc.param #param_desc("string", "prefix", "New administrator's prefix. Must
     * match one of the values available in the web UI. (i.e. Dr., Mr., Mrs., Sr., etc.)")
     * @xmlrpc.param #param_desc("string", "firstName", "New administrator's first name.")
     * @xmlrpc.param #param_desc("string", "lastName", "New administrator's first name.")
     * @xmlrpc.param #param_desc("string", "email", "New administrator's e-mail.")
     * @xmlrpc.param #param_desc("boolean", "usePamAuth", "True if PAM authentication
     * should be used for the new administrator account.")
     * @xmlrpc.returntype $OrgDtoSerializer
     */
    public OrgDto create(User loggedInUser, String orgName, String adminLogin,
            String adminPassword, String prefix, String firstName, String lastName,
            String email, Boolean usePamAuth) {
        log.debug("OrgHandler.create");
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);

        validateCreateOrgData(orgName, adminPassword, firstName, lastName, email,
                usePamAuth);

        CreateOrgCommand cmd = new CreateOrgCommand(orgName, adminLogin, adminPassword,
                email, false);
        cmd.setFirstName(firstName);
        cmd.setLastName(lastName);
        cmd.setPrefix(prefix);

        String pamAuthService = Config.get().getString(ConfigDefaults.WEB_PAM_AUTH_SERVICE);
        if (usePamAuth) {
            if (pamAuthService != null && pamAuthService.trim().length() > 0) {
                cmd.setUsePam(usePamAuth);
            }
            else {
                // The user wants to use pam authentication, but the server has not been
                // configured to use pam... Throw an error...
                throw new PamAuthNotConfiguredException();
            }
        }

        ValidatorError[] verrors = cmd.store();
        if (verrors != null) {
            throw new ValidationException(verrors[0].getMessage());
        }

        return OrgManager.toDetailsDto(cmd.getNewOrg());
    }

    private void validateCreateOrgData(String orgName, String password, String firstName,
            String lastName, String email, Boolean usePamAuth) {

        Map<String, String> values = new HashMap<String, String>();
        values.put("orgName", orgName);
        values.put("desiredPassword", password);
        values.put("desiredPasswordConfirm", password);
        values.put("firstNames", firstName);
        values.put("lastName", lastName);

        ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                values, new LinkedList<String>(values.keySet()), VALIDATION_XSD);

        if (!result.isEmpty()) {
            log.error("Validation errors:");
            for (ValidatorError error : result.getErrors()) {
                log.error("   " + error.getMessage());
            }
            // Multiple errors could return here, but we'll have to just throw an
            // exception for the first one and return that to the user.
            ValidatorError e = result.getErrors().get(0);
            throw new ValidationException(e.getMessage());
        }

        if (!usePamAuth && StringUtils.isEmpty(password)) {
            throw new FaultException(-501, "passwordRequiredOrUsePam",
                    "Password is required if not using PAM authentication");
        }
    }

    /**
     * Returns the list of organizations.
     * @param loggedInUser The current user
     * @return list of orgs.
     * @xmlrpc.doc Returns the list of organizations.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *   #array()
     *     $OrgDtoSerializer
     *   #array_end()
     */
    public List<OrgDto> listOrgs(User loggedInUser) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        return OrgManager.activeOrgs(loggedInUser);
    }

    /**
     * Delete an organization.
     *
     * @param loggedInUser The current user
     * @param orgId ID of organization to delete.
     * @return 1 on success, exception thrown otherwise.
     *
     * @xmlrpc.doc Delete an organization. The default organization
     * (i.e. orgId=1) cannot be deleted.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);

        // Verify we're not trying to delete the default org (id 1):
        Org defaultOrg = OrgFactory.getSatelliteOrg();
        if (orgId.longValue() == defaultOrg.getId().longValue()) {
            throw new SatelliteOrgException();
        }

        OrgFactory.deleteOrg(org.getId(), loggedInUser);

        return 1;
    }

    private Org verifyOrgExists(String name) {
        Org org = OrgFactory.lookupByName(name);
        if (org == null) {
            throw new NoSuchOrgException(name);
        }
        return org;
    }

    /**
     * Returns the list of active users in a given organization
     * @param loggedInUser The current user
     * @param orgId the orgId of the organization to lookup on.
     * @return the list of users in a organization.
     * @xmlrpc.doc Returns the list of users in a given organization.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype
     *   #array()
     *     $MultiOrgUserOverviewSerializer
     *   #array_end()
     */
    public List listUsers(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        verifyOrgExists(orgId);
        return OrgManager.activeUsers(Long.valueOf(orgId));
    }

    /**
     * Returns the detailed information about an organization
     * given the org_id.
     * @param loggedInUser The current user
     * @param orgId the orgId of the organization to lookup on.
     * @return the list of users in a organization.
     *
     * @xmlrpc.doc The detailed information about an organization given
     * the organization ID.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype $OrgDtoSerializer
     */
    public OrgDto getDetails(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        return OrgManager.toDetailsDto(verifyOrgExists(orgId));
    }

    /**
     * Returns the detailed information about an organization
     * given the org_name.
     * @param loggedInUser The current user
     * @param name the name of the organization to lookup on.
     * @return the list of users in a organization.
     *
     * @xmlrpc.doc The detailed information about an organization given
     * the organization name.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "name")
     * @xmlrpc.returntype $OrgDtoSerializer
     */
    public OrgDto getDetails(User loggedInUser, String name) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        return OrgManager.toDetailsDto(verifyOrgExists(name));
    }

    /**
     *
     * @param loggedInUser The current user
     * @param orgId the orgId of the organization to set name on
     * @param name the new name for the org.
     * @return the updated org.
     *
     * @xmlrpc.doc Updates the name of an organization
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param_desc("string", "name", "Organization name. Must meet same
     * criteria as in the web UI.")
     * @xmlrpc.returntype $OrgDtoSerializer
     */
    public OrgDto updateName(User loggedInUser, Integer orgId, String name) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        if (!org.getName().equals(name)) {
            try {
                OrgManager.checkOrgName(name);
                org.setName(name);
            }
            catch (ValidatorException ve) {
                throw new ValidationException(ve.getMessage());
            }
        }
        return OrgManager.toDetailsDto(org);
    }

    /**
     * Lookup a channel family, throwing an exception if it cannot be found.
     *
     * @param channelFamilyLabel Channel family label to look up.
     */
    private ChannelFamily lookupChannelFamily(String channelFamilyLabel) {
        ChannelFamily cf = ChannelFamilyFactory.lookupByLabel(channelFamilyLabel, null);
        if (cf == null) {
            throw new InvalidEntitlementException();
        }
        return cf;
    }

    /**
     * Migrate systems from one organization to another.  If executed by
     * a Satellite administrator, the systems will be migrated from their current
     * organization to the organization specified by the toOrgId.  If executed by
     * an organization administrator, the systems must exist in the same organization
     * as that administrator and the systems will be migrated to the organization
     * specified by the toOrgId. In any scenario, the origination and destination
     * organizations must be defined in a trust.
     *
     * @param loggedInUser The current user
     * @param toOrgId destination organization ID.
     * @param sids System IDs.
     * @return list of systems migrated.
     * @throws FaultException A FaultException is thrown if:
     *   - The user performing the request is not an organization administrator
     *   - The user performing the request is not a satellite administrator, but the
     *     from org id is different than the user's org id.
     *   - The from and to org id provided are the same.
     *   - One or more of the servers provides do not exist
     *   - The origination or destination organization does not exist
     *   - The user is not defined in the destination organization's trust
     *
     * @xmlrpc.doc Migrate systems from one organization to another.  If executed by
     * a Satellite administrator, the systems will be migrated from their current
     * organization to the organization specified by the toOrgId.  If executed by
     * an organization administrator, the systems must exist in the same organization
     * as that administrator and the systems will be migrated to the organization
     * specified by the toOrgId. In any scenario, the origination and destination
     * organizations must be defined in a trust.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "toOrgId", "ID of the organization where the
     * system(s) will be migrated to.")
     * @xmlrpc.param #array_single("int", "systemId")
     * @xmlrpc.returntype
     * #array_single("int", "serverIdMigrated")
     */
    public Object[] migrateSystems(User loggedInUser, Integer toOrgId,
            List<Integer> sids) throws FaultException {

        // the user executing the request must at least be an org admin to perform
        // a system migration
        ensureUserRole(loggedInUser, RoleFactory.ORG_ADMIN);

        Org toOrg = verifyOrgExists(toOrgId);

        List<Server> servers = new LinkedList<Server>();

        for (Integer sid : sids) {
            Long serverId = new Long(sid.longValue());
            Server server = null;
            try {
                server = ServerFactory.lookupById(serverId);

                // throw a no_such_system exception if the server was not found.
                if (server == null) {
                    throw new NoSuchSystemException("No such system - sid[" + sid + "]");
                }
            }
            catch (LookupException e) {
                throw new NoSuchSystemException("No such system - sid[" + sid + "]");
            }
            servers.add(server);

            // As a pre-requisite to performing the actual migration, verify that each
            // server that is planned for migration passes the criteria that follows.
            // If any of the servers fails that criteria, none will be migrated.

            // unless the user is a satellite admin, they are not permitted to migrate
            // systems from an org that they do not belong to
            if ((!loggedInUser.hasRole(RoleFactory.SAT_ADMIN)) &&
                    (!loggedInUser.getOrg().equals(server.getOrg()))) {
                throw new PermissionCheckFailureException(server);
            }

            // do not allow the user to migrate systems to/from the same org.  doing so
            // would essentially remove entitlements, channels...etc from the systems
            // being migrated.
            if (toOrg.equals(server.getOrg())) {
                throw new MigrationToSameOrgException(server);
            }

            // if the originating org is not defined within the destination org's trust
            // the migration should not be permitted.
            if (!toOrg.getTrustedOrgs().contains(server.getOrg())) {
                throw new OrgNotInTrustException(server);
            }
        }

        List<Long> serversMigrated = MigrationManager.migrateServers(loggedInUser,
                toOrg, servers);
        return serversMigrated.toArray();
    }

    /**
     * Get organization wide crash file size limit.
     *
     * @param loggedInUser The current user
     * @param orgId Organization ID to set the limit for.
     * @return Returns the organization wide crash file size limit.
     *
     * @xmlrpc.doc Get the organization wide crash file size limit. The limit value
     * must be a non-negative number, zero means no limit.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype int - Crash file size limit.
     */
    public int getCrashFileSizeLimit(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        return org.getOrgConfig().getCrashFileSizelimit().intValue();
    }

    /**
     * Set organization wide crash file size limit.
     *
     * @param loggedInUser The current user
     * @param orgId Organization ID to set the limit for.
     * @param limit The limit to set.
     * @return 1 on success.
     *
     * @xmlrpc.doc Set the organization wide crash file size limit. The limit value
     * must be non-negative, zero means no limit.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param_desc("int", "limit", "The limit to set (non-negative value).")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setCrashFileSizeLimit(User loggedInUser, Integer orgId, Integer limit) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        if (limit < 0) {
            throw new InvalidParameterException("Limit value must be non-negative.");
        }
        org.getOrgConfig().setCrashFileSizelimit(new Long(limit.longValue()));

        return 1;
    }

    /**
     * Get the status of crash reporting settings for the given organization.
     *
     * @param loggedInUser The current user
     * @param orgId Organization ID to set the limit for.
     * @return Returns the status of crash reporting settings.
     *
     * @xmlrpc.doc Get the status of crash reporting settings for the given organization.
     * Returns true if enabled, false otherwise.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype boolean - Get the status of crash reporting settings.
     */
    public boolean isCrashReportingEnabled(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        return org.getOrgConfig().isCrashReportingEnabled();
    }

    /**
     * Set the status of crash reporting settings for the given organization.
     *
     * @param loggedInUser The current user
     * @param orgId Organization ID to set the limit for.
     * @param enable Boolean to indicate desired settings.
     * @return Returns 1 for successfull change, traceback otherwise.
     *
     * @xmlrpc.doc Set the status of crash reporting settings for the given organization.
     * Disabling crash reporting will automatically disable crash file upload.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param_desc("boolean", "enable", "Use true/false to enable/disable")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer setCrashReporting(User loggedInUser, Integer orgId,
                                     Boolean enable) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        if (enable) {
            org.getOrgConfig().setCrashReportingEnabled(enable);
        }
        else {
            org.getOrgConfig().setCrashReportingEnabled(false);
            org.getOrgConfig().setCrashfileUploadEnabled(false);
        }

        return 1;
    }

    /**
     * Get the status of crash file upload settings for the given organization.
     *
     * @param loggedInUser The current user
     * @param orgId Organization ID to set the limit for.
     * @return Returns the status of crash file upload settings.
     *
     * @xmlrpc.doc Get the status of crash file upload settings for the given organization.
     * Returns true if enabled, false otherwise.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype boolean - Get the status of crash file upload settings.
     */
    public boolean isCrashfileUploadEnabled(User loggedInUser, Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        return org.getOrgConfig().isCrashfileUploadEnabled();
    }

    /**
     * Set the status of crash file upload settings for the given organization.
     *
     * @param loggedInUser The current user
     * @param orgId Organization ID to set the limit for.
     * @param enable Boolean to indicate desired settings.
     * @return Returns 1 for successfull change, 0 if the change failed.
     *
     * @xmlrpc.doc Set the status of crash file upload settings for the given organization.
     * Modifying the settings is possible as long as crash reporting is enabled.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param_desc("boolean", "enable", "Use true/false to enable/disable")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer setCrashfileUpload(User loggedInUser, Integer orgId,
                                      Boolean enable) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        if (org.getOrgConfig().isCrashReportingEnabled()) {
            org.getOrgConfig().setCrashfileUploadEnabled(enable);
        }
        else {
            return 0;
        }

        return 1;
    }

    /**
     * Get the status of SCAP detailed result file upload settings for the given
     * organization.
     *
     * @param loggedInUser The current user
     * @param orgId ID of organization to query.
     * @return Returns the status of SCAP detailed result file upload settings.
     *
     * @xmlrpc.doc Get the status of SCAP detailed result file upload settings
     * for the given organization.
     *
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype
     *     #struct("scap_upload_info")
     *         #prop_desc("boolean", "enabled",
     *             "Aggregation of detailed SCAP results is enabled.")
     *         #prop_desc("int", "size_limit",
     *             "Limit (in Bytes) for a single SCAP file upload.")
     *     #struct_end()
     */
    public Map<String, Object> getPolicyForScapFileUpload(User loggedInUser,
            Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("enabled", org.getOrgConfig().isScapfileUploadEnabled());
        result.put("size_limit", org.getOrgConfig().getScapFileSizelimit());
        return result;
    }

    /**
     * Set the status of SCAP detailed result file upload settings for the given
     * organization.
     *
     * @param loggedInUser The current user
     * @param orgId ID of organization to work with.
     * @param newSettings New settings of the SCAP detailed result file upload.
     * @return Returns 1 for successfull change.
     *
     * @xmlrpc.doc Set the status of SCAP detailed result file upload settings
     * for the given organization.
     *
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param
     *     #struct("scap_upload_info")
     *         #prop_desc("boolean", "enabled",
     *             "Aggregation of detailed SCAP results is enabled.")
     *         #prop_desc("int", "size_limit",
     *             "Limit (in Bytes) for a single SCAP file upload.")
     *     #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setPolicyForScapFileUpload(User loggedInUser, Integer orgId,
            Map<String, Object> newSettings) {
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("enabled");
        validKeys.add("size_limit");
        validateMap(validKeys, newSettings);

        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        OrgConfig orgConfig = verifyOrgExists(orgId).getOrgConfig();
        if (newSettings.containsKey("enabled")) {
            Boolean enabled = (Boolean) newSettings.get("enabled");
            orgConfig.setScapfileUploadEnabled(enabled);
        }
        if (newSettings.containsKey("size_limit")) {
            Long sizeLimit = new Long(((Integer)
                newSettings.get("size_limit")).longValue());
            orgConfig.setScapFileSizelimit(sizeLimit);
        }
        return 1;
    }

    /**
     * Get the status of SCAP result deletion settings for the given organization.
     *
     * @param loggedInUser The current user
     * @param orgId ID of organization to query.
     * @return Returns the status of SCAP result deletion settings.
     *
     * @xmlrpc.doc Get the status of SCAP result deletion settings for the given
     * organization.
     *
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype
     *     #struct("scap_deletion_info")
     *         #prop_desc("boolean", "enabled", "Deletion of SCAP results is enabled")
     *         #prop_desc("int", "retention_period",
     *             "Period (in days) after which a scan can be deleted (if enabled).")
     *     #struct_end()
     */
    public Map<String, Object> getPolicyForScapResultDeletion(User loggedInUser,
            Integer orgId) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        Long retentionPeriod = org.getOrgConfig().getScapRetentionPeriodDays();
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("enabled", retentionPeriod != null);
        result.put("retention_period",
                (retentionPeriod != null) ? retentionPeriod : new Long(0));
        return result;
    }

    /**
     * Set the status of SCAP result deletion settings for the given organization.
     *
     * @param loggedInUser The current user
     * @param orgId ID of organization to work with.
     * @param newSettings New settings of the SCAP result deletion settings.
     * @return Returns 1 for successfull change.
     *
     * @xmlrpc.doc Set the status of SCAP result deletion settins for the given
     * organization.
     *
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param
     *     #struct("scap_deletion_info")
     *         #prop_desc("boolean", "enabled",
     *             "Deletion of SCAP results is enabled")
     *         #prop_desc("int", "retention_period",
     *             "Period (in days) after which a scan can be deleted (if enabled).")
     *     #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setPolicyForScapResultDeletion(User loggedInUser, Integer orgId,
            Map<String, Object> newSettings) {
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("enabled");
        validKeys.add("retention_period");
        validateMap(validKeys, newSettings);

        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        OrgConfig orgConfig = verifyOrgExists(orgId).getOrgConfig();
        if (newSettings.containsKey("enabled")) {
            if ((Boolean) newSettings.get("enabled")) {
                orgConfig.setScapRetentionPeriodDays(new Long(90));
            }
            else {
                orgConfig.setScapRetentionPeriodDays(null);
            }
        }
        if (newSettings.containsKey("retention_period")) {
            Long retentionPeriod = new Long(((Integer)
                newSettings.get("retention_period")).longValue());
            if (orgConfig.getScapRetentionPeriodDays() != null) {
                orgConfig.setScapRetentionPeriodDays(retentionPeriod);
            }
        }
        return 1;
    }

    /**
     * Returns whether Organization Administrator is able to manage his organization
     * configuration. This organization configuration may have a high impact on the whole
     * Spacewalk/Satellite performance
     *
     * @param loggedInUser The current user
     * @param orgId affected organization
     * @return Returns the status org admin management setting
     *
     * @xmlrpc.doc Returns whether Organization Administrator is able to manage his
     * organization configuration. This organization configuration may have a high impact
     * on the whole Spacewalk/Satellite performance
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype boolean - Returns the status org admin management setting
     */
    public boolean isOrgConfigManagedByOrgAdmin(User loggedInUser, Integer orgId) {
        verifyManagesOrgConfig(loggedInUser, orgId);
        Org org = verifyOrgExists(orgId);
        return org.getOrgAdminMgmt().isEnabled();
    }

    /**
     * Sets whether Organization Administrator can manage his organization configuration
     *
     * @param loggedInUser The current user
     * @param orgId affected organization id
     * @param enable boolean to indicate permissions of Organization Administrator to manage
     * organization configuration
     * @return Returns 1 for successful change, exception otherwise
     *
     * @xmlrpc.doc Sets whether Organization Administrator can manage his organization
     * configuration. This organization configuration may have a high impact
     * on the whole Spacewalk/Satellite performance
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param_desc("boolean", "enable", "Use true/false to enable/disable")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer setOrgConfigManagedByOrgAdmin(User loggedInUser, Integer orgId,
                                      Boolean enable) {
        ensureUserRole(loggedInUser, RoleFactory.SAT_ADMIN);
        Org org = verifyOrgExists(orgId);
        org.getOrgAdminMgmt().setEnabled(enable);

        return 1;
    }

    /**
     * verifies the user can manage org configuration
     * - either he's a sat admin
     * - or he's an org admin and OrgAdminManagement is set for the org
     */
    private boolean verifyManagesOrgConfig(User user, Integer orgId)
            throws PermissionCheckFailureException {
        Org org = verifyOrgExists(orgId);
        if (user.hasRole(RoleFactory.SAT_ADMIN) ||
                user.hasRole(RoleFactory.ORG_ADMIN) && org.getOrgAdminMgmt().isEnabled()) {
            return true;
        }
        throw new PermissionCheckFailureException();
    }

    /**
     * Returns whether errata e-mail notifications are enabled for the organization
     *
     * @param loggedInUser The current user
     * @param orgId affected organization
     * @return Returns the status of the errata e-mail notification setting
     * for the organization
     *
     * @xmlrpc.doc Returns whether errata e-mail notifications are enabled
     * for the organization
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.returntype boolean - Returns the status of the errata e-mail notification
     * setting for the organization
     */
    public boolean isErrataEmailNotifsForOrg(User loggedInUser, Integer orgId) {
        verifyManagesOrgConfig(loggedInUser, orgId);
        Org org = verifyOrgExists(orgId);
        return org.getOrgConfig().isErrataEmailsEnabled();
    }

    /**
     * Dis/enables errata e-mail notifications for the organization
     *
     * @param loggedInUser The current user
     * @param orgId affected organization id
     * @param enable boolean to indicate errata e-mail notifications are enabled
     * for the organization
     * @return Returns 1 for successful change, exception otherwise
     *
     * @xmlrpc.doc Dis/enables errata e-mail notifications for the organization
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "orgId")
     * @xmlrpc.param #param_desc("boolean", "enable", "Use true/false to enable/disable")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer setErrataEmailNotifsForOrg(User loggedInUser, Integer orgId,
                                      Boolean enable) {
        verifyManagesOrgConfig(loggedInUser, orgId);
        Org org = verifyOrgExists(orgId);
        org.getOrgConfig().setErrataEmailsEnabled(enable);

        return 1;
    }
}
