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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * ChannelSystemDeploySetup
 * @version $Rev$
 */
public class ChannelSystemDeploySetup extends BaseSetListAction {

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNEL_DEPLOY_SYSTEMS;
    }

    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        User usr = rctx.getLoggedInUser();
        ConfigChannel cc = ConfigActionHelper.getChannel(rctx.getRequest());
        return ConfigurationManager.getInstance().listSystemInfoForChannel(usr, cc, pc);
    }

    protected void processRequestAttributes(RequestContext rctx) {
        if (!rctx.isSubmitted()) {
            getSetDecl().clear(rctx.getLoggedInUser());
        }
        super.processRequestAttributes(rctx);
        ConfigChannel cc = ConfigActionHelper.getChannel(rctx.getRequest());
        ConfigActionHelper.setupRequestAttributes(rctx, cc);
    }

    protected Map makeParamMap(HttpServletRequest request) {
        Map m = super.makeParamMap(request);
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        ConfigActionHelper.processParamMap(cc, m);
        return m;
    }

    protected void processPageControl(PageControl pc) {
        pc.setFilterColumn("name");
        pc.setFilter(true);
    }
}
