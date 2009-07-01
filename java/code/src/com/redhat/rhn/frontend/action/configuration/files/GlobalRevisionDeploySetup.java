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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * GlobalRevisionDeploySetup
 * @version $Rev$
 */
public class GlobalRevisionDeploySetup extends BaseSetListAction {
    
    protected DataResult getDataResult(RequestContext ctx, PageControl pc) {
        User usr = ctx.getLoggedInUser();
        ConfigFile cf = ConfigActionHelper.getFile(ctx.getRequest());
        ConfigChannel cc = cf.getConfigChannel();
        DataResult dr = ConfigurationManager.getInstance().
            listGlobalFileDeployInfo(usr, cc, cf, pc);
        return dr;
    }

    protected void processRequestAttributes(RequestContext rctxIn) {
        ConfigActionHelper.processRequestAttributes(rctxIn);
        super.processRequestAttributes(rctxIn);
    }
    
    protected void processPageControl(PageControl pc) {
        pc.setFilterColumn("name");
        pc.setFilter(true);
    }

    /**
     * We affect the selected-files set
     * @return FILE_LISTS identifier
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILE_DEPLOY_SYSTEMS;
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        // Clear the set of systems if this is a new request, prevents stale system
        // selections from hanging around if the user didn't complete their previous
        // attempt:
        if (!requestContext.isSubmitted()) {
            RhnSet set = getSetDecl().get(requestContext.getCurrentUser());
            set.clear();
            RhnSetFactory.save(set);
        }

        return super.execute(mapping, formIn, request, response);
    }

}
