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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.action.ActionManager;

import org.apache.struts.action.ActionForm;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * RemoveConfirmSetupAction
 * @version $Rev$
 */
public class RemoveConfirmSetupAction extends BaseSystemPackagesConfirmAction {

    private static final PackageListSetupAction DECL_ACTION = new PackageListSetupAction();
    protected static final String PACKAGE_REMOVE = "remove";

    @Override
    protected String getRemoteMode() {
        return PACKAGE_REMOVE;
    }

    @Override
    protected String getDecl(Long sid) {
        return DECL_ACTION.getDecl(sid);
    }

    @Override
    protected String getMessageKeyForMany() {
        return "message.packageremovals";
    }

    @Override
    protected String getMessageKeyForOne() {
        return "message.packageremoval";
    }

    @Override
    protected PackageAction schedulePackageAction(ActionForm formIn,
            RequestContext context, List<Map<String, Long>> pkgs, Date earliest) {
        return ActionManager.schedulePackageRemoval(context.getLoggedInUser(),
                context.lookupAndBindServer(), pkgs, earliest);
    }

    @Override
    protected String getWidgetSummary() {
        return "removeconfirm.jsp.widgetsummary";
    }

    @Override
    protected String getHeaderKey() {
        return "removeconfirm.jsp.confirmpackageremoval";
    }
}
