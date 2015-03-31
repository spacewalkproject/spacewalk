/**
 * Copyright (c) 2013 SUSE LLC
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

package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerCommand.Operation;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerPowerSettingsUpdateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.satellite.SystemCommandExecutor;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.SystemRecord;
import org.cobbler.XmlRpcException;

import java.util.Arrays;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Saves power settings and boots machines.
 */
public class PowerManagementAction extends RhnAction {

    /** The log. */
    private static Logger log = Logger.getLogger(PowerManagementAction.class);
    public static final String TYPES = "types";
    public static final String POWER_TYPE = "powerType";
    public static final String POWER_ADDRESS = "powerAddress";
    public static final String POWER_USERNAME = "powerUsername";
    public static final String POWER_PASSWORD = "powerPassword";
    public static final String POWER_NO_AGENT = "powerNoAgent";

    /** Attribute name. */
    public static final String POWER_ID = "powerId";

    /** Attribute name. */
    public static final String POWER_STATUS_ON = "powerStatusOn";

    /**
     * Runs this action.
     *
     * @param mapping action mapping
     * @param formIn form submitted values
     * @param request http request object
     * @param response http response object
     * @return an action forward object
     */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
        HttpServletRequest request, HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) formIn;
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        User user = context.getCurrentUser();
        Long sid = context.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        ActionErrors errors = new ActionErrors();

        if (context.isSubmitted()) {
            CobblerPowerSettingsUpdateCommand command = getPowerSettingsUpdateCommand(form,
                    user, server);
            ValidatorError error;
            if (context.wasDispatched(
                    "kickstart.powermanagement.jsp.remove.cobblerprofile")) {
                error = command.removeSystemProfile();
                if (error == null) {
                    log.debug("Cobbler system profile removed for system " + sid);
                    addMessage(request, "kickstart.powermanagement.removed.cobblerprofile");
                }
            }
            else {
                error = command.store();
                if (error == null) {
                    log.debug("Power management settings saved for system " + sid);
                    if (context.wasDispatched("kickstart.powermanagement.jsp.save_only")) {
                        addMessage(request, "kickstart.powermanagement.saved");
                    }
                    if (context.wasDispatched("kickstart.powermanagement.jsp.power_on")) {
                        error = new CobblerPowerCommand(user, server, Operation.PowerOn)
                            .store();
                        if (error == null) {
                            log.debug("Power on succeded for system " + sid);
                            addMessage(request, "kickstart.powermanagement.powered_on");
                        }
                    }
                    if (context.wasDispatched("kickstart.powermanagement.jsp.power_off")) {
                        error = new CobblerPowerCommand(user, server, Operation.PowerOff)
                            .store();
                        if (error == null) {
                            log.debug("Power off succeded for system " + sid);
                            addMessage(request, "kickstart.powermanagement.powered_off");
                        }
                    }
                    if (context.wasDispatched("kickstart.powermanagement.jsp.reboot")) {
                        error = new CobblerPowerCommand(user, server, Operation.Reboot).
                                store();
                        if (error == null) {
                            log.debug("Reboot succeded for system " + sid);
                            addMessage(request, "kickstart.powermanagement.rebooted");
                        }
                    }
                    if (context.wasDispatched(
                        "kickstart.powermanagement.jsp.get_status")) {
                        try {
                            SystemRecord record = getSystemRecord(user, server);
                            request.setAttribute(POWER_STATUS_ON, record.getPowerStatus());
                            addMessage(request, "kickstart.powermanagement.saved");
                        }
                        catch (XmlRpcException e) {
                            log.warn("Could not get power status from Cobbler for system " +
                                server.getId());
                            createErrorMessage(request,
                                    "kickstart.powermanagement.jsp.power_status_failed",
                                    null);
                        }
                    }
                }
            }

            if (error != null) {
                strutsDelegate.addError(errors, error.getKey(), error.getValues());
                strutsDelegate.saveMessages(request, errors);
            }
        }

        setAttributes(request, context, server, user, strutsDelegate, errors);

        return strutsDelegate.forwardParams(
            mapping.findForward(RhnHelper.DEFAULT_FORWARD), request.getParameterMap());
    }

    /**
     * Returns a CobblerPowerSettingsUpdateCommand from form data.
     * Empty form data means - clear the value in cobbler.
     * @param form the form
     * @param user currently logged in user
     * @param server server to update
     * @return the command
     */
    public static CobblerPowerSettingsUpdateCommand getPowerSettingsUpdateCommand(
            DynaActionForm form, User user, Server server) {
        return new CobblerPowerSettingsUpdateCommand(
            user, server, form.getString(POWER_TYPE), form.getString(POWER_ADDRESS),
            form.getString(POWER_USERNAME), form.getString(POWER_PASSWORD),
            form.getString(POWER_ID));
    }

    /**
     * Returns a CobblerPowerSettingsUpdateCommand from form data.
     * With SSM empty form data means - do not change the value.
     * @param form the form
     * @param user currently logged in user
     * @param server server to update
     * @return the command
     */
    public static CobblerPowerSettingsUpdateCommand getPowerSettingsUpdateCommandSSM(
            DynaActionForm form, User user, Server server) {
        return new CobblerPowerSettingsUpdateCommand(
            user, server, form.getString(POWER_TYPE),
            StringUtils.trimToNull(form.getString(POWER_ADDRESS)),
            StringUtils.trimToNull(form.getString(POWER_USERNAME)),
            StringUtils.trimToNull(form.getString(POWER_PASSWORD)),
            StringUtils.trimToNull(form.getString(POWER_ID)));
    }

    /**
     * Sets the page attributes.
     *
     * @param request the request
     * @param context the context
     * @param server the server
     * @param user the user
     * @param strutsDelegate the Struts delegate
     * @param errors ActionErrors that might have already been raised
     */
    private void setAttributes(HttpServletRequest request, RequestContext context,
            Server server, User user, StrutsDelegate strutsDelegate, ActionErrors errors) {
        request.setAttribute(RequestContext.SID, server.getId());
        request.setAttribute(RequestContext.SYSTEM, server);

        SortedMap<String, String> types = setUpPowerTypes(request, strutsDelegate, errors);
        ensureAgentInstalled(request, strutsDelegate, errors);
        if (types.size() > 0) {
            SystemRecord record = getSystemRecord(user, server);

            if (record == null) {
                request.setAttribute(POWER_TYPE, types.get(types.firstKey()));
            }
            else {
                request.setAttribute(POWER_TYPE, record.getPowerType());
                request.setAttribute(POWER_ADDRESS, record.getPowerAddress());
                request.setAttribute(POWER_USERNAME, record.getPowerUsername());
                request.setAttribute(POWER_PASSWORD, record.getPowerPassword());
                request.setAttribute(POWER_ID, record.getPowerId());
            }
        }
    }

    /**
     * Sets up and returns a list of supported Cobbler power types.
     * @param request the current request
     * @param strutsDelegate the Struts delegate
     * @param errors ActionErrors that might have already been raised
     * @return the types
     */
    public static SortedMap<String, String> setUpPowerTypes(HttpServletRequest request,
            StrutsDelegate strutsDelegate, ActionErrors errors) {
        SortedMap<String, String> types = new TreeMap<String, String>();
        String typeString = ConfigDefaults.get().getCobblerPowerTypes();
        if (typeString != null) {
            List<String> typeNames = Arrays.asList(typeString.split(" *, *"));
            for (String typeName : typeNames) {
                types.put(
                    LocalizationService.getInstance().getPlainText(
                        "cobbler.powermanagement." + typeName), typeName);
            }
        }
        request.setAttribute(TYPES, types);

        if (types.size() == 0) {
            strutsDelegate.addError(errors, "kickstart.powermanagement.jsp.no_types",
                ConfigDefaults.POWER_MANAGEMENT_TYPES);
            strutsDelegate.saveMessages(request, errors);
        }
        return types;
    }

    /**
     * Return the Cobbler system record corresponding to the system
     * @param user current user
     * @param server server to look up
     * @return a Cobbler system record
     */
    private SystemRecord getSystemRecord(User user, Server server) {
        return SystemRecord.lookupById(
            CobblerXMLRPCHelper.getConnection(user), server.getCobblerId());
    }

    /**
     * Ensure a fence agent is installed, raise an error and disable fields if not
     * @param request the current request
     * @param strutsDelegate the Struts delegate
     * @param errors ActionErrors that might have already been raised
     */
    public static void ensureAgentInstalled(HttpServletRequest request,
            StrutsDelegate strutsDelegate, ActionErrors errors) {
        // written this way instead of one rpm command because if any of the rpms passed
        // to a single rpm command are not installed the return status is 1
        String[] rhelRpm = { "rpm", "-q", "fence-agents" };
        String[] fedoraRpm = { "rpm", "-q", "fence-agents-all" };
        String[] fedoraSpecificRpm = { "rpm", "-q", "fence-agents" };
        SystemCommandExecutor ce = new SystemCommandExecutor();
        if (ce.execute(rhelRpm) != 0 && ce.execute(fedoraRpm) != 0 &&
                ce.execute(fedoraSpecificRpm) != 0) {
            strutsDelegate.addError(errors, "cobbler.powermanagement.no_fence_agents");
            strutsDelegate.saveMessages(request, errors);
            // overwrite types with an empty list to disable pages
            request.setAttribute(TYPES, new TreeMap<String, String>());
        }
    }
}
