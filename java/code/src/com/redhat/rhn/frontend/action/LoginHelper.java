/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.common.SatConfigFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.org.usergroup.UserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.manager.user.CreateUserCommand;
import com.redhat.rhn.manager.user.UpdateUserCommand;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


/**
 * LoginHelper
 * @version $Rev$
 */
public class LoginHelper {

    private static Logger log = Logger.getLogger(LoginHelper.class);
    private static final String DEFAULT_KERB_USER_PASSWORD = "0";

    /**
     * Utility classes can't be instantiated.
     */
    private LoginHelper() {
    }

    /**
     * check whether we can login an externally authenticated user
     * @param request request
     * @param messages messages
     * @param errors errors
     * @return user, if externally authenticated
     */
    public static User checkExternalAuthentication(HttpServletRequest request,
            ActionMessages messages,
            ActionErrors errors) {
        String remoteUserString = request.getRemoteUser();
        User remoteUser = null;
        if (remoteUserString != null) {

            String firstname = decodeFromIso88591(
                    (String) request.getAttribute("REMOTE_USER_FIRSTNAME"), "");
            String lastname = decodeFromIso88591(
                    (String) request.getAttribute("REMOTE_USER_LASTNAME"), "");
            String email = decodeFromIso88591(
                    (String) request.getAttribute("REMOTE_USER_EMAIL"), null);

            Set<Role> roles = getRolesFromExtGroups(request);

            log.warn("REMOTE_USER_GROUPS: " +
                    request.getAttribute("REMOTE_USER_GROUPS"));

                try {
                    remoteUser = UserFactory.lookupByLogin(remoteUserString);

                if (remoteUser.isDisabled()) {
                    errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("account.user.disabled",
                                    new String[] {remoteUserString}));
                    remoteUser = null;
                }
                if (remoteUser != null) {
                    UpdateUserCommand updateCmd = new UpdateUserCommand(remoteUser);
                    updateCmd.setFirstNames(firstname);
                    updateCmd.setLastName(lastname);
                    updateCmd.setEmail(email);
                    updateCmd.setRoles(roles);
                    updateCmd.updateUser();
                    log.warn("Externally authenticated login " + remoteUserString +
                                 " (" + firstname + " " + lastname + ")");
                }
            }
            catch (LookupException le) {
                Org newUserOrg = null;
                Boolean useOrgUnit = SatConfigFactory.getSatConfigBooleanValue(
                        SatConfigFactory.EXT_AUTH_USE_ORGUNIT);
                if (useOrgUnit) {
                    String orgUnitString =
                            (String) request.getAttribute("REMOTE_USER_ORGUNIT");
                    newUserOrg = OrgFactory.lookupByName(orgUnitString);
                    if (newUserOrg == null) {
                        log.error("Cannot find organization with name: " + orgUnitString);
                    }
                }
                if (newUserOrg == null) {
                    Long defaultOrgId = SatConfigFactory.getSatConfigLongValue(
                            SatConfigFactory.EXT_AUTH_DEFAULT_ORGID);
                    if (defaultOrgId != null) {
                        newUserOrg = OrgFactory.lookupById(defaultOrgId);
                        if (newUserOrg == null) {
                            log.error("Cannot find organization with id: " + defaultOrgId);
                        }
                    }
                }
                if (newUserOrg != null) {
                    CreateUserCommand createCmd = new CreateUserCommand();
                    createCmd.setLogin(remoteUserString);
                    // set a password, that cannot really be used
                    createCmd.setRawPassword(DEFAULT_KERB_USER_PASSWORD);
                    createCmd.setFirstNames(firstname);
                    createCmd.setLastName(lastname);
                    createCmd.setEmail(email);
                    createCmd.setOrg(newUserOrg);
                    createCmd.setRoles(roles);
                    createCmd.validate();
                    createCmd.storeNewUser();
                    remoteUser = createCmd.getUser();
                    log.warn("Externally authenticated login " + remoteUserString +
                            " (" + firstname + " " + lastname + ") created in " +
                            newUserOrg.getName() + ".");
                }
                if (remoteUser != null &&
                        remoteUser.getPassword().equals(DEFAULT_KERB_USER_PASSWORD)) {
                    messages.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("message.kerbuserlogged",
                                    new String[] {remoteUserString}));
                }
            }
        }
        return remoteUser;
    }

    private static String decodeFromIso88591(String string, String defaultString) {
        try {
            if (string != null) {
                return new String(string.getBytes("ISO8859-1"), "UTF-8");
            }
        }
        catch (UnsupportedEncodingException e) {
            log.warn("Unable to decode: " + string);
        }
        return defaultString;
    }

    private static Set<Role> getRolesFromExtGroups(HttpServletRequest requestIn) {
        Set<Role> roles = new HashSet<Role>();
        Long nGroups = null;
        String nGroupsStr = (String) requestIn.getAttribute("REMOTE_USER_GROUP_N");
        if (nGroupsStr != null) {
            try {
                nGroups = Long.parseLong(nGroupsStr);
            }
            catch (NumberFormatException nfe) {
                // do nothing, nGroups stays null
            }
        }
        if (nGroups == null) {
            log.warn("REMOTE_USER_GROUP_N not set!");
            return roles;
        }
        for (int i = 1; i <= nGroups; i++) {
            String extGroupName = (String) requestIn.getAttribute("REMOTE_USER_GROUP_" + i);
            if (extGroupName == null) {
                log.warn("REMOTE_USER_GROUP_" + i + " not set!");
                continue;
            }
            UserExtGroup extGroup = UserGroupFactory.lookupExtGroupByLabel(extGroupName);
            if (extGroup == null) {
                log.warn("No mapping defined for external group '" + extGroupName + "'.");
                continue;
            }
            roles.addAll(extGroup.getRoles());
        }
        return roles;
    }

    /** static method shared by LoginAction and LoginSetupAction
     * @param request actual request
     * @param response actual reponse
     * @param user logged in user
     * @return returns true, if redirect
     */
    public static boolean successfulLogin(HttpServletRequest request,
            HttpServletResponse response, User user) {
        // set last logged in
        user.setLastLoggedIn(new Date());
        UserManager.storeUser(user);
        // update session with actual user
        PxtSessionDelegateFactory.getInstance().newPxtSessionDelegate().
            updateWebUserId(request, response, user.getId());

        LoginHelper.publishUpdateErrataCacheEvent(user.getOrg());
        // redirect, if url_bounce set
        HttpSession ws = request.getSession(false);
        if (ws != null) {
            String urlBounce = LoginAction.updateUrlBounce(
                    (String) ws.getAttribute("url_bounce"),
                    (String) ws.getAttribute("request_method"));
            try {
                if (urlBounce != null) {
                    log.info("redirect: " + urlBounce);
                    response.sendRedirect(urlBounce);
                    return true;
                }
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    /**
     * @param orgIn
     */
    private static void publishUpdateErrataCacheEvent(Org orgIn) {
        StopWatch sw = new StopWatch();
        if (log.isDebugEnabled()) {
            log.debug("Updating errata cache");
            sw.start();
        }

        UpdateErrataCacheEvent uece = new
            UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_ORG);
        uece.setOrgId(orgIn.getId());
        MessageQueue.publish(uece);

        if (log.isDebugEnabled()) {
            sw.stop();
            log.debug("Finished Updating errata cache. Took [" +
                    sw.getTime() + "]");
        }
    }

}
