/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.configuration.overview;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.MultipleChannelsWithPackageException;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * TargetSystemsSubmitAction
 * Handles pagination and RhnSet until the enable button is clicked, then
 * redirects to the confirm page.
 * @version $Rev$
 */
public class TargetSystemsSubmitAction extends RhnSetAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn,
                                       ActionForm formIn,
                                       HttpServletRequest requestIn) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listNonManagedSystems(userIn, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_ENABLE_SYSTEMS;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map<String, String> mapIn) {
        mapIn.put("targetsystems.jsp.enable", "enableSystems");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form,
                                   HttpServletRequest request,
                                   Map<String, Object> params) {
        getStrutsDelegate().rememberDatePicker(params, (DynaActionForm)form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
    }

    /**
     * Go to the confirm page.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request struts HttpServletRequest
     * @param response struts HttpServletResponse
     * @return The confirm ActionForward
     */
    public ActionForward enableSystems(ActionMapping mapping,
                                          ActionForm formIn,
                                  HttpServletRequest request,
                                 HttpServletResponse response) {
        updateSet(request);
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();

        //get the earliest date for package actions.
        DynaActionForm form = (DynaActionForm) formIn;
        Date earliest = getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);

        try {
            ConfigurationManager.getInstance().enableSystems(getSetDecl(), user, earliest);
        }
        catch (MultipleChannelsWithPackageException e) {
            ValidatorError verrors = new ValidatorError("config.multiple.channels");
            ActionErrors errors = RhnValidationHelper.validatorErrorToActionErrors(verrors);
            getStrutsDelegate().saveMessages(request, errors);
            return mapping.findForward("default");
        }
        return mapping.findForward("summary");
    }

}
