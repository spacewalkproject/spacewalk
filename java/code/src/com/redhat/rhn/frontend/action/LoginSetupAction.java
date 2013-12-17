/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.satellite.CertificateManager;
import com.redhat.rhn.manager.satellite.SystemCommandExecutor;
import com.redhat.rhn.manager.user.CreateUserCommand;
import com.redhat.rhn.manager.user.UpdateUserCommand;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * LoginSetupAction
 * @version $Rev$
 */
public class LoginSetupAction extends RhnAction {

    private static Logger log = Logger.getLogger(LoginSetupAction.class);
    public static final String HAS_EXPIRED = "hasExpired";
    private static final String DEFAULT_KERB_USER_PASSWORD = "0";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
        ActionForm form, HttpServletRequest request,
        HttpServletResponse response) {

        String rpmSchemaVersion = getRpmSchemaVersion("satellite-schema");
        if (rpmSchemaVersion == null) {
            rpmSchemaVersion = getRpmSchemaVersion("spacewalk-schema");
        }

        SelectMode m = ModeFactory.getMode("General_queries", "installed_schema_version");
        DataResult<HashMap> dr = m.execute();
        String installedSchemaVersion = null;
        if (dr.size() > 0) {
            installedSchemaVersion = (String) dr.get(0).get("version");
        }

        if (log.isDebugEnabled()) {
            log.debug("RPM version of schema: " +
                (rpmSchemaVersion == null ? "null" : rpmSchemaVersion));
            log.debug("Version of installed database schema: " +
                (installedSchemaVersion == null ? "null" : installedSchemaVersion));
        }

        if (rpmSchemaVersion != null && installedSchemaVersion != null &&
            !rpmSchemaVersion.equals(installedSchemaVersion)) {
            request.setAttribute("schemaUpgradeRequired", "true");
        }
        else {
            request.setAttribute("schemaUpgradeRequired", "false");
        }

        CertificateManager man = CertificateManager.getInstance();
        if (man.isSatelliteCertInRestrictedPeriod()) {
            createErrorMessageWithMultipleArgs(request, "satellite.expired.restricted",
                    man.getDayProgressInRestrictedPeriod());
        }
        else if (man.isSatelliteCertExpired()) {
            addMessage(request, "satellite.expired");
            request.setAttribute(HAS_EXPIRED, Boolean.TRUE);
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
        else if (man.isSatelliteCertInGracePeriod()) {
            long daysUntilExpiration = man.getDaysLeftBeforeCertExpiration();
            createSuccessMessage(request,
                "satellite.graceperiod",
                String.valueOf(daysUntilExpiration));
        }
        else if (!UserManager.satelliteHasUsers()) {
            return mapping.findForward("needuser");
        }

        if (AclManager.hasAcl("user_authenticated()", request, null)) {
            return mapping.findForward("loggedin");
        }

        String remoteUserString = request.getRemoteUser();
        if (remoteUserString != null) {

            String firstname = decodeFromIso88591(
                    (String) request.getAttribute("REMOTE_USER_FIRSTNAME"), "");
            String lastname = decodeFromIso88591(
                    (String) request.getAttribute("REMOTE_USER_LASTNAME"), "");
            String email = decodeFromIso88591(
                    (String) request.getAttribute("REMOTE_USER_EMAIL"), null);

            User remoteUser = null;
            try {
                log.info("REMOTE_USER_CUSTOM_N: " +
                        request.getAttribute("REMOTE_USER_CUSTOM_N"));
                log.info("REMOTE_USER_GECOS: " +
                        request.getAttribute("REMOTE_USER_GECOS"));
                log.info("REMOTE_USER_GROUPS: " +
                        request.getAttribute("REMOTE_USER_GROUPS"));

                remoteUser = UserFactory.lookupByLogin(remoteUserString);

                if (remoteUser.isDisabled()) {
                    createErrorMessage(request, "account.user.disabled", remoteUserString);
                    remoteUser = null;
                }
                else {
                    UpdateUserCommand updateCmd = new UpdateUserCommand(remoteUser);
                    updateCmd.setFirstNames(firstname);
                    updateCmd.setLastName(lastname);
                    updateCmd.setEmail(email);
                    updateCmd.updateUser();
                    log.warn("Kerberos login " + remoteUserString + " (" + firstname + " " +
                            lastname + ")");
                }
            }
            catch (LookupException le) {
                Long defaultOrgId = ConfigDefaults.get().getIpaDefaultUserOrgId();
                Org defaultOrg = OrgFactory.lookupById(defaultOrgId);
                if (defaultOrg == null) {
                    log.warn("Cannot find organization with id: " + defaultOrgId);
                }
                else {
                    CreateUserCommand createCmd = new CreateUserCommand();
                    createCmd.setLogin(remoteUserString);
                    // set a password, that cannot really be used
                    createCmd.setRawPassword(DEFAULT_KERB_USER_PASSWORD);
                    createCmd.setFirstNames(firstname);
                    createCmd.setLastName(lastname);
                    createCmd.setEmail(email);
                    createCmd.setOrg(defaultOrg);
                    createCmd.validate();
                    createCmd.storeNewUser();
                    remoteUser = createCmd.getUser();
                    log.warn("Kerberos login " + remoteUserString + " (" + firstname + " " +
                            lastname + ") created.");
                }
            }
            if (remoteUser != null) {
                if (remoteUser.getPassword().equals(DEFAULT_KERB_USER_PASSWORD)) {
                    createMessage(request, "message.kerbuserlogged",
                            new String [] {remoteUserString});
                }
                if (LoginAction.successfulLogin(request, response, remoteUser)) {
                    return null;
                }
                return mapping.findForward("loggedin");
            }
        }

        // store url_bounce set by pxt pages
        String urlBounce = request.getParameter("url_bounce");
        if (!StringUtils.isBlank(urlBounce)) {
            HttpSession hs = request.getSession();
            if (hs != null) {
                hs.setAttribute("url_bounce", urlBounce);
            }
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private String decodeFromIso88591(String string, String defaultString) {
        try {
            return new String(string.getBytes("ISO8859-1"), "UTF-8");
        }
        catch (UnsupportedEncodingException e) {
            log.warn("Unable to decode: " + string);
            return defaultString;
        }
    }

    private String getRpmSchemaVersion(String schemaName) {
        String[] rpmCommand = new String[4];
        rpmCommand[0] = "rpm";
        rpmCommand[1] = "-q";
        rpmCommand[2] = "--qf=%{VERSION}-%{RELEASE}";
        rpmCommand[3] = schemaName;
        SystemCommandExecutor ce = new SystemCommandExecutor();
        return ce.execute(rpmCommand) == 0 ?
            ce.getLastCommandOutput().replace("\n", "") : null;
    }
}
