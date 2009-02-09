/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.kickstart.cobbler;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.cobbler.BaseCobblerSnippetCommand;
import com.redhat.rhn.manager.kickstart.cobbler.DeleteCobblerSnippetCommand;

/**
 * CobblerSnippetDeleteAction 
 * @version $Rev: 1 $
 */
public class CobblerSnippetDeleteAction extends BaseCobblerSnippetEditAction {
    
    /**
     * {@inheritDoc}
     */
    protected BaseCobblerSnippetCommand getCommand(RequestContext ctx) {
        return new DeleteCobblerSnippetCommand(ctx.getParam(RequestContext.NAME, true));
    }
    
    /**
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "cobblersnippet.delete.success";
    }
    
    /**
     * {@inheritDoc}
     */
    protected boolean isContentsRequired() {
        return false;
    }
}
