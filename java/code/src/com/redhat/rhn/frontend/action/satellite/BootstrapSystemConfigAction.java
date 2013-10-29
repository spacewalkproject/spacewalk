/**
 * Copyright (c) 2013 SUSE
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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDisableBootstrapCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerEnableBootstrapCommand;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Enables or disable bare-metal system bootstrap image as default PXE booting
 * option.
 * @version $Rev$
 */
public class BootstrapSystemConfigAction extends RhnAction {
    /** Submit input value */
    public static final String ENABLE = "enable";
    /** Submit input value */
    public static final String DISABLE = "disable";
    /** Attribute key */
    public static final String CURRENT_ORG = "currentOrg";
    /** Attribute key */
    public static final String ENABLED_ORG = "enabledOrg";
    /** Attribute key */
    public static final String ENABLED_FOR_OTHER_ORG = "enabledForOtherOrg";
    /** Attribute key */
    public static final String ENABLED_FOR_CURRENT_ORG = "enabledForCurrentOrg";
    /** Attribute key */
    public static final String DISABLED = "disabled";
    /** Used to force skipping Cobbler file checks in tests */
    public static final String SKIP_FILE_CHECKS = "skipFileChecks";

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
        HttpServletRequest request, HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);

        if (ctx.isSubmitted()) {
            if (ctx.hasParam(ENABLE)) {
                executeEnableBootstrapDiscovery(request, ctx);
            }
            if (ctx.hasParam(DISABLE)) {
                executeDisableBootstrapDiscovery(request, ctx);
            }
        }

        setAttributes(request, ctx);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Enables bootstrap discovery.
     * @param request the request
     * @param ctx the context
     */
    private void executeEnableBootstrapDiscovery(HttpServletRequest request,
        RequestContext ctx) {
        CobblerEnableBootstrapCommand cmd = new CobblerEnableBootstrapCommand(
            ctx.getCurrentUser(), ctx.hasParam(SKIP_FILE_CHECKS));
        ValidatorError ve = cmd.store();
        addMessages(request, ve, "bootstrapsystems.jsp.bootstrap_enabled");
    }

    /**
     * Disables bootstrap discovery.
     * @param request the request
     * @param ctx the context
     */
    private void executeDisableBootstrapDiscovery(HttpServletRequest request,
        RequestContext ctx) {
        CobblerDisableBootstrapCommand cmd = new CobblerDisableBootstrapCommand(
            ctx.getCurrentUser());
        ValidatorError ve = cmd.store();
        addMessages(request, ve, "bootstrapsystems.jsp.bootstrap_disabled");
    }

    /**
     * Sets the page attributes.
     * @param request the request
     * @param ctx the context
     */
    private void setAttributes(HttpServletRequest request, RequestContext ctx) {
        User user = ctx.getCurrentUser();
        List<ActivationKey> previousActivationKeys = ActivationKeyManager.getInstance()
            .findBootstrap();
        Org currentOrg = user.getOrg();
        Org enabledOrg = null;
        if (previousActivationKeys.size() > 0) {
            enabledOrg = previousActivationKeys.get(0).getOrg();
        }
        request.setAttribute(CURRENT_ORG, currentOrg.getName());
        request.setAttribute(ENABLED_ORG, enabledOrg == null ? null : enabledOrg.getName());
        request.setAttribute(DISABLED, enabledOrg == null);
        request.setAttribute(ENABLED_FOR_CURRENT_ORG, currentOrg.equals(enabledOrg));
        request.setAttribute(ENABLED_FOR_OTHER_ORG,
            enabledOrg != null && !currentOrg.equals(enabledOrg));
    }

    /**
     * Adds a success message or a validator error to the page
     * @param request the request
     * @param validatorError a validation error or null
     * @param successMessage a success message string
     */
    private void addMessages(HttpServletRequest request, ValidatorError validatorError,
        String successMessage) {
        if (validatorError == null) {
            addMessage(request, successMessage);
        }
        else {
            ActionErrors errors = new ActionErrors();
            getStrutsDelegate().addError(errors, validatorError.getKey(),
                validatorError.getValues());
            getStrutsDelegate().saveMessages(request, errors);
        }
    }
}
