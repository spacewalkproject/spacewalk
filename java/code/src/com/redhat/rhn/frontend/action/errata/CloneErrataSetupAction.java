/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CloneErrataSetupAction
 * 
 * @version $Rev$
 */
public class CloneErrataSetupAction extends RhnListAction {

    /** {@inheritDoc} */
    public final ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
            DynaActionForm daForm = (DynaActionForm) formIn;
            RequestContext rctx = new RequestContext(request);
            User user = rctx.getLoggedInUser();
            DataResult dr;
            
            PageControl pc = new PageControl();
            pc.setFilterColumn("earliest");

            clampListBounds(pc, request, user);
            
            RhnSet set = RhnSetDecl.ERRATA_CLONE.get(user);
            
            /* If the user submitted the form, we find out what channel
             * errata they are trying to look at from the form. Otherwise,
             * we just show them all errata not already cloned in all managed
             * channels
             */
            if (isSubmitted(daForm)) {
                ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, 
                                                                                 daForm);
                
                if (!errors.isEmpty()) {
                    getStrutsDelegate().saveMessages(request, errors);
                    return mapping.findForward("error");
                }
                
                dr = CloneErrataActionHelper.getSubmittedDataResult(rctx, daForm, pc);
            }
            else {
                dr = CloneErrataActionHelper.getUnsubmittedDataResult(rctx, pc);
            }
            
            request.setAttribute("pageList", dr);
            request.setAttribute("set", set);
            processDropDownList(rctx);
            
            return mapping.findForward("default");
    }
    
    protected void processDropDownList(RequestContext rctx) {
        List displayList = new ArrayList();
        LocalizationService ls = LocalizationService.getInstance();
        displayList.add(new LabelValueBean(ls.getMessage("cloneerrata.anychannel"), 
                                           CloneErrataActionHelper.ANY_CHANNEL));
        List l = ChannelManager.
            getChannelsWithClonableErrata(rctx.getCurrentUser().getOrg());
        
        if (l != null) {
            for (Iterator i = l.iterator(); i.hasNext();) {
                Channel c = (Channel) i.next();
                // /me wonders if this shouldn't be part of the query.
                if ("rpm".equals(c.getChannelArch().getArchType().getLabel())) {
                    displayList.add(new LabelValueBean(c.getName(), 
                            "channel_" + c.getId()));    
                }
            }  
        }

        
        rctx.getRequest().setAttribute("clonablechannels", displayList);
    }
    
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ERRATA_CLONE;
    }
}
