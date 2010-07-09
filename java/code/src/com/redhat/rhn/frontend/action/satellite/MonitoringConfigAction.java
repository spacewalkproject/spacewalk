/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.satellite;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.monitoring.config.ConfigMacro;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.NameDescriptionValue;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.satellite.ConfigureSatelliteCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * MonitoringConfigAction - adds the list of configuration
 * parameters to the request
 * @version $Rev: 53528 $
 */
public class MonitoringConfigAction extends BaseConfigAction {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(MonitoringConfigAction.class);

    public static final String IS_MONITORING_SCOUT = "is_monitoring_scout";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) {
        if (logger.isDebugEnabled()) {
            logger.debug("execute(ActionMapping mapping=" + mapping +
                    ", ActionForm formIn=" + formIn +
                    ", HttpServletRequest req=" + req +
                    ", HttpServletResponse resp=" + resp + ") - start");
        }
        RequestContext requestContext = new RequestContext(req);

        DynaActionForm form = (DynaActionForm) formIn;
        User user = requestContext.getLoggedInUser();

        List configList = getManager().
            getEditableConfigMacros(user);
        // Simple flag to flip if we actually changed anything on the form
        boolean valuesChanged = false;
        List nameDescVals = new LinkedList();
        Iterator i = configList.iterator();
        // Localize the display values
        while (i.hasNext()) {
            ConfigMacro ci = (ConfigMacro) i.next();
            // If the user submitted the form and there exists a value
            Object param = req.getParameter(ci.getName());
            if (param != null) {
                if (!param.equals(ci.getDefinition())) {
                    ci.setDefinition((String) param);
                    getManager().storeConfigMacro(ci);
                    valuesChanged = true;
                }
            }
            if (logger.isDebugEnabled()) {
                logger.debug("execute() - Name: " + ci.getName() +
                        " value: " + ci.getDefinition());
            }
            nameDescVals.add(new NameDescriptionValue(ci.getName(),
                    LocalizationService.getInstance().getMessage(ci.getName()),
                    ci.getDefinition()));

        }

        if (isSubmitted(form)) {
            ConfigureSatelliteCommand csc = (ConfigureSatelliteCommand) getCommand(user);
            csc.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT,
                    (Boolean) form.get(IS_MONITORING_SCOUT));
            if (csc.getKeysToBeUpdated().size() > 0) {
                valuesChanged = true;
                ValidatorError[] verrors = csc.storeConfiguration();
                if (verrors != null) {
                    ActionErrors errors =
                        RhnValidationHelper.validatorErrorToActionErrors(verrors);
                    getStrutsDelegate().saveMessages(req, errors);
                }
            }
            if (valuesChanged) {
                // Restart the Monitoring services
                boolean restarted = getManager().restartMonitoringServices(user);
                if (restarted) {
                    createSuccessMessage(req, "monitoring.services.restarted", "");
                }
            }
            else {
                createSuccessMessage(req, "monitoring.services.novalueschanged", "");
            }
        }
        else {
            form.set(IS_MONITORING_SCOUT,
                    new Boolean(Config.get().getBoolean(
                            ConfigDefaults.WEB_IS_MONITORING_SCOUT)));
        }

        req.setAttribute("configList", nameDescVals);
        ActionForward returnActionForward = mapping.findForward("default");
        if (logger.isDebugEnabled()) {
            logger.debug("execute(ActionMapping, ActionForm, " +
                    "HttpServletRequest, HttpServletResponse)" +
                    " - end - return value=" + returnActionForward);
        }
        return returnActionForward;
    }

    /**
     * Method that can be overriden to provide a different MonitoringManager
     * @return MonitoringManager instance
     */
    protected MonitoringManager getManager() {
        if (logger.isDebugEnabled()) {
            logger.debug("getManager() - start");
        }


        MonitoringManager returnMonitoringManager = MonitoringManager
                .getInstance();
        if (logger.isDebugEnabled()) {
            logger.debug("getManager() - end - return value=" +
                    returnMonitoringManager);
        }
        return returnMonitoringManager;
    }

    /**
     * {@inheritDoc}
     */
    protected String getCommandClassName() {
        if (logger.isDebugEnabled()) {
            logger.debug("getCommandClassName() - start");
        }

        String returnString = Config.get().getString(
                "web.com.redhat.rhn.frontend." +
                "action.satellite.MonitoringConfigAction.command",
                "com.redhat.rhn.manager.satellite.ConfigureSatelliteCommand");
        if (logger.isDebugEnabled()) {
            logger.debug("getCommandClassName() - end - return value=" +
                    returnString);
        }
        return returnString;
    }

}
