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

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.PersistOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation;

import org.apache.struts.action.DynaActionForm;

/**
 * TreeCreate class for creating Kickstart Trees
 * @version $Rev: 1 $
 */
public class TreeCreateAction extends BaseTreeAction {
    
    protected String getSuccessKey() {
        return "tree.create.success";
    }

    protected PersistOperation getCommand(RequestContext ctx) {
        return new TreeCreateOperation(ctx.getCurrentUser());
    }

    protected void processFormValues(PersistOperation operation, DynaActionForm form) {
        // NOOOP For create
    }

}
