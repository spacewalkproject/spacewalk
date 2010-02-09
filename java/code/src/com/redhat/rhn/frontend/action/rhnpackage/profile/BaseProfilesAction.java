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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnLookupDispatchAction;

import org.apache.struts.Globals;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

/**
 * BaseProfilesAction is an abstract class which aids in
 * removing duplicate code from the profile actions.
 * @version $Rev: 60028 $
 */
public abstract class BaseProfilesAction extends RhnLookupDispatchAction {

    protected void createMessage(HttpServletRequest req, String key,
            List params) {
        ActionMessages msg = null;
        if (req.getAttribute(Globals.MESSAGE_KEY) != null) {
            msg = (ActionMessages) req.getAttribute(Globals.MESSAGE_KEY);
        }
        else if (req.getSession().getAttribute(Globals.MESSAGE_KEY) != null) {
            msg = (ActionMessages) req.getSession().getAttribute(Globals.MESSAGE_KEY);
        }
        else {
            msg = new ActionMessages();
        }
        
        if (params != null && !params.isEmpty()) {
            Object[] args = params.toArray();
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
        }
        else {
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key));
        }
        
        getStrutsDelegate().saveMessages(req, msg);
    }
    
    protected void addHardwareMessage(PackageAction pa, RequestContext rctx) {
        // If we scheduled a hardware refresh too
        if (pa != null && pa.getPrerequisite() != null) {
            // NOTE: Hardware refresh has been scheduled for 
            // cascade.sfbay.redhat.com to be run before the 
            // package profile sync.  This is required to verify that the 
            // system has the ability to compare packages.
            List hwargs = new ArrayList();
            hwargs.add(rctx.lookupAndBindServer().getId().toString());
            hwargs.add(pa.getPrerequisite().toString());
            hwargs.add(rctx.lookupAndBindServer().getName());
            createMessage(rctx.getRequest(), "message.hardwarerefresh", hwargs);
        }

    }
    
    protected void createMessage(HttpServletRequest req, String key) {
        createMessage(req, key, null);
    }
}
