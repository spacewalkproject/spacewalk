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
package com.redhat.rhn.frontend.action.kickstart.tree;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.PersistOperation;
import com.redhat.rhn.manager.kickstart.tree.BaseTreeEditOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeDeleteOperation;

import org.apache.struts.action.DynaActionForm;

import java.util.List;

/**
 * TreeDeleteAction  class for deleting Kickstart Trees
 * @version $Rev: 1 $
 */
public class TreeDeleteAction extends BaseTreeAction {
    
    protected String getSuccessKey() {
        return "tree.delete.success";
    }
    
    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx, PersistOperation opr) {
        super.processRequestAttributes(rctx, opr);
        BaseTreeEditOperation bte = (BaseTreeEditOperation) opr;
        List profiles = KickstartFactory.lookupKickstartDatasByTree(bte.getTree());
        if (profiles != null && profiles.size() > 0) {
            rctx.getRequest().setAttribute(RequestContext.PAGE_LIST, 
                    new DataResult(profiles));
        }
        rctx.getRequest().setAttribute(RequestContext.KSTREE, bte.getTree());
        
    }
    
    /**
     * {@inheritDoc}
     */
    protected PersistOperation getCommand(RequestContext ctx) {
        return new TreeDeleteOperation(ctx.getRequiredParam(RequestContext.KSTREE_ID), 
                                            ctx.getCurrentUser());
    }

    /**
     * {@inheritDoc}
     */
    protected void processFormValues(PersistOperation operation, DynaActionForm form) {
        // NOOOP For delete
    }
    
    /**
     * {@inheritDoc}
     */
    protected ValidatorError processCommandSetters(PersistOperation operation, 
                                                            DynaActionForm form) {
       return null;
    }

}
