/**
 * Copyright (c) 2010 Red Hat, Inc.
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

import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.events.SsmDeleteServersEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * SSMDeleteSystemsConfirm
 * @version $Rev$
 */
public class SSMDeleteSystemsConfirm extends RhnAction implements Listable {
    /**
     * 
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        if (context.wasDispatched("ssm.delete.systems.confirmbutton")) {
            return handleConfirm(context, mapping);
        }
        
        ListHelper helper = new ListHelper(this, request);
        helper.setListName("systemList");
        helper.setDataSetName("pageList");
        helper.execute();

        return mapping.findForward("default");
    }
    
    private ActionForward handleConfirm(RequestContext context,
            ActionMapping mapping) {
        
        RhnSet set = RhnSetDecl.SYSTEMS.get(context.getLoggedInUser());
        
        // Fire the request off asynchronously
        SsmDeleteServersEvent event =
            new SsmDeleteServersEvent(context.getLoggedInUser(),
                            new ArrayList<Long>(set.getElementValues()));
        MessageQueue.publish(event);
        set.clear();
        RhnSetManager.store(set);
        
        
        getStrutsDelegate().saveMessage("ssm.delete.systems.confirmmessage",
                                                    context.getRequest());
        return mapping.findForward("confirm");
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        return SystemManager.inSet(contextIn.getLoggedInUser(),
                                        RhnSetDecl.SYSTEMS.getLabel());
    }

}
