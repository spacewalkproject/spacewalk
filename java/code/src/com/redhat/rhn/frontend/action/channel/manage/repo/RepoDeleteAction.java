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
package com.redhat.rhn.frontend.action.channel.manage.repo;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.repo.EditRepoCommand;

/**
 * RepoDeleteAction 
 * @version $Rev: 1 $
 */
public class RepoDeleteAction extends RhnAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        EditRepoCommand cmd = new EditRepoCommand(context.getLoggedInUser(), 
                context.getParamAsLong("id"));  
        
        ContentSource src = cmd.getNewRepo();
        
        request.setAttribute(RepoDetailsAction.LABEL, src.getLabel() );
        request.setAttribute(RepoDetailsAction.URL, src.getSourceUrl() );
        request.setAttribute("id", src.getId());
        
        if (context.isSubmitted()) {
            try {
                //delete here
                createSuccessMessage(request, 
                            "repos.delete.success", cmd.getLabel());
                return mapping.findForward("success");
            }
            catch (ValidatorException ve) {
                getStrutsDelegate().saveMessages(request, ve.getResult());
                RhnValidationHelper.setFailedValidation(request);
            }
        }
        
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
