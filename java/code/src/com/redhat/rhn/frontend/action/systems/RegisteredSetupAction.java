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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RegisteredSetupAction
 * @version $Rev$
 */
public class RegisteredSetupAction extends BaseSystemsAction {
    public static final String[] OPTIONS = {"oneday", 
                                            "oneweek", 
                                            "onemonth", 
                                            "sixmonths", 
                                            "oneyear",
                                            "allregisteredsystems"};
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        ActionForward forward = super.execute(mapping, formIn, request, response);
        LocalizationService ls = LocalizationService.getInstance();
        List optionsLabelValueBeans = new ArrayList();
        
        for (int j = 0; j < OPTIONS.length; ++j) {
            optionsLabelValueBeans.add(new LabelValueBean(ls.getMessage(OPTIONS[j]), 
                                                                        OPTIONS[j]));
        }
        
        request.setAttribute("options", optionsLabelValueBeans);
        return forward;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, PageControl pc, ActionForm formIn) {
        DynaActionForm daForm = (DynaActionForm) formIn;
        
        String thresholdString = daForm.getString("threshold");
        /* by default our threshold is one day */
        int threshold = 1;
        
        if (isSubmitted(daForm) && thresholdString != null) {
            if (thresholdString.equals("oneweek")) {
                threshold = 7;
            }
            else if (thresholdString.equals("onemonth")) {
                threshold = 30;
            }
            else if (thresholdString.equals("sixmonths")) {
                threshold = 180;
            }
            else if (thresholdString.equals("oneyear")) {
                threshold = 365;
            }
            else if (thresholdString.equals("allregisteredsystems")) {
                threshold = 0;
            }
        }

        DataResult dr = SystemManager.registeredList(user, pc, threshold);
        return dr;
    }

}
