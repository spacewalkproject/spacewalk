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
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.satellite.ConfigureSatelliteCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * GeneralConfigAction - Struts action to handle updating config values from
 * the satellte General Config page.
 *
 * @version $Rev: 1 $
 */
public class GeneralConfigAction extends BaseConfigAction {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(GeneralConfigAction.class);


    private static final String[] STRING_CONFIG_ARRAY = {"traceback_mail",
        "server.jabber_server", "server.satellite.http_proxy",
        "server.satellite.http_proxy_username", "server.satellite.http_proxy_password",
        "mount_point"};

    private static final String[] BOOLEAN_CONFIG_ARRAY = {"web.ssl_available",
        "web.enable_solaris_support", ConfigDefaults.DISCONNECTED,
            "web.is_monitoring_backend"};

    private static final List COMBO_LIST = new LinkedList();
    static {
        COMBO_LIST.addAll(Arrays.asList(STRING_CONFIG_ARRAY));
        COMBO_LIST.addAll(Arrays.asList(BOOLEAN_CONFIG_ARRAY));
    }

    private final List BOOLEAN_CONFIGS = Arrays.asList(BOOLEAN_CONFIG_ARRAY);

    /** List of Config keys allowed by this Action */
    public static final List ALLOWED_CONFIGS = COMBO_LIST;

    /*
     * enable_ssl, disconnected, mount_point
     */

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        if (logger.isDebugEnabled()) {
            logger.debug("execute(ActionMapping mapping=" + mapping +
                    ", ActionForm formIn=" + formIn +
                    ", HttpServletRequest request=" + request +
                    ", HttpServletResponse response=" + response +
                    ") - start");
        }

        ActionErrors errors;
        ActionForward returnActionForward;

        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext rctx = new RequestContext(request);
        User currentUser = rctx.getCurrentUser();
        if (isSubmitted(form)) {
            ConfigureSatelliteCommand csc =
                (ConfigureSatelliteCommand) getCommand(currentUser);
            Iterator i = ALLOWED_CONFIGS.iterator();

            errors = validateForm(form);
            errors.add(RhnValidationHelper.validateDynaActionForm(this, form));


            if (!errors.isEmpty()) {
                getStrutsDelegate().saveMessages(request, errors);
                addErrors(request, errors);
                return mapping.findForward("failure");
            }


            while (i.hasNext()) {
                String configKey = (String) i.next();
                // Have to munge the property name to replace the dots with | since
                // struts attempts to 'beanify' the form propert values if you include
                // dot notation in the names.

                if (BOOLEAN_CONFIGS.contains(configKey)) {
                    Boolean value = (Boolean)
                        form.get(translateFormPropertyName(configKey));
                    csc.updateBoolean(configKey, value);
                }
                else {
                    String value = (String)
                        form.get(translateFormPropertyName(configKey));
                    csc.updateString(configKey, value);
                }
            }
            ValidatorError[] verrors = csc.storeConfiguration();
            if (verrors != null) {
                errors = RhnValidationHelper.validatorErrorToActionErrors(verrors);
                getStrutsDelegate().saveMessages(request, errors);
                addErrors(request, errors);
            }
            else {
                addMessage(request, "config.restartrequired");
            }
        }
        else {
            Iterator i = ALLOWED_CONFIGS.iterator();
            while (i.hasNext()) {
                String configKey = (String) i.next();

                if (BOOLEAN_CONFIGS.contains(configKey)) {
                    boolean configValue = Config.get().getBoolean(configKey);
                    form.set(translateFormPropertyName(configKey),
                            new Boolean(configValue));
                }
                else {
                    String configValue = Config.get().getString(configKey);
                    form.set(translateFormPropertyName(configKey),
                            configValue);

                    if (configKey.equals("server.satellite.http_proxy_password")) {
                        form.set(
              translateFormPropertyName("server.satellite.http_proxy_password_confirm"),
              configValue);
                    }
                }
            }
        }
        returnActionForward = mapping.findForward("default");
        if (logger.isDebugEnabled()) {
            logger.debug("execute(ActionMapping, ActionForm, HttpServletRequest," +
                    " HttpServletResponse) - end - return value=" +
                    returnActionForward);
        }
        return returnActionForward;
    }

    /**
     * Key munging method to replace the DOTs in the key with |'s
     * This is because Struts will attempt to turn any form property
     * that contains dot notation into a bean and then use BeanUtils
     * to inquire about properties of that bean.  For form properties
     * that are not a bean, this causes null/empty values to be returned.
     *
     * @param configKey to replace periods with bars
     * @return String with |s instead of .s
     */
    public static String translateFormPropertyName(String configKey) {
        return configKey.replace('.', '|');
    }

    /**
     * {@inheritDoc}
     */
    protected String getCommandClassName() {
        return Config.get().getString("web.com.redhat.rhn.frontend." +
                "action.satellite.GeneralConfigAction.command",
                "com.redhat.rhn.manager.satellite.ConfigureSatelliteCommand");
    }

    /**
     * This function checks if the user entered a valid e-mail, hostname,
     * and if the password and password confirmation fields match. Any
     * errors found are returned.
     * @param GeneralConfingForm to validate
     * @return errors that were found in the submitted form
     */
    private ActionErrors validateForm(DynaActionForm form) {
        ActionErrors errors = new ActionErrors();
        String email = (String) form.get(translateFormPropertyName("traceback_mail"));
        String password = (String) form.get(
                   translateFormPropertyName("server.satellite.http_proxy_password"));
        String confirmationPassword = (String) form.get(
           translateFormPropertyName("server.satellite.http_proxy_password_confirm"));

        if (!password.equals(confirmationPassword)) {
            form.set(
                    translateFormPropertyName("server.satellite.http_proxy_password"),
                    "");

            form.set(
                    translateFormPropertyName
                    ("server.satellite.http_proxy_password_confirm"),
                    "");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("error.password_mismatch"));
        }

        return errors;
    }

}

