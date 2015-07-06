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

import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.PersistOperation;
import com.redhat.rhn.manager.kickstart.tree.BaseTreeEditOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeEditOperation;

import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;

/**
 * TreeEditAction
 * @version $Rev$
 */
public class TreeEditAction extends BaseTreeAction {

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx, PersistOperation opr) {
        BaseTreeEditOperation bte = (BaseTreeEditOperation) opr;
        rctx.getRequest().setAttribute(RequestContext.KSTREE, bte.getTree());
        super.processRequestAttributes(rctx, opr);
        if (!rctx.isSubmitted()) {
            checkDistroValidity(rctx.getRequest(), bte);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "tree.edit.success";
    }

    /**
     * {@inheritDoc}
     */
    protected PersistOperation getCommand(RequestContext ctx) {
        if (ctx.getRequest().getParameter(RequestContext.KSTREE_ID) != null) {
            ctx.getRequest().setAttribute(RequestContext.KSTREE_ID,
                    ctx.getRequest().getParameter(RequestContext.KSTREE_ID));
        }

        return new TreeEditOperation(ctx.getRequiredParam(RequestContext.KSTREE_ID),
                ctx.getCurrentUser());
    }

    /**
     * {@inheritDoc}
     */
    protected void processFormValues(PersistOperation operation,
            DynaActionForm form) {
        BaseTreeEditOperation bte = (BaseTreeEditOperation) operation;
        KickstartableTree tree = bte.getTree();
        form.set(BASE_PATH, tree.getBasePath());
        form.set(CHANNEL_ID, tree.getChannel().getId());
        form.set(LABEL, tree.getLabel());
        form.set(INSTALL_TYPE, tree.getInstallType().getLabel());
        form.set(KERNEL_OPTS, tree.getKernelOptions());
        form.set(POST_KERNEL_OPTS, tree.getKernelOptionsPost());
    }

    private void checkDistroValidity(HttpServletRequest request,
                                        BaseTreeEditOperation bte) {
        try {
            bte.validateBasePath();
            if (!bte.getTree().isValid()) {
                ValidatorResult result = new ValidatorResult();
                result.addError("tree.edit.invalid_tree");
                getStrutsDelegate().saveMessages(request, result);
            }
        }
        catch (ValidatorException ve) {
            getStrutsDelegate().saveMessages(request, ve.getResult());
        }
    }
}
