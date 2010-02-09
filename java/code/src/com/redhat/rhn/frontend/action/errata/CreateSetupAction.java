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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CreateSetupAction
 * @version $Rev$
 */
public class CreateSetupAction extends RhnAction {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        
        if (StringUtils.isBlank(form.getString("advisoryRelease"))) {
            //set advisory release field to 1
            form.set("advisoryRelease", LocalizationService.getInstance()
                                                       .formatNumber(new Long(1)));
        }
        
        //set advisoryTypes list for select drop down
        request.setAttribute("advisoryTypes", ErrataManager.advisoryTypes());

        //set l10n-ed advisoryTypeLabels list for select drop down
        form.set("advisoryTypeLabels", ErrataManager.advisoryTypeLabels());
        
        return mapping.findForward("default");
    }
}
